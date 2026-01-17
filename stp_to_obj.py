import gmsh
import argparse
import os
import sys
import trimesh
import numpy as np

def main():
    parser = argparse.ArgumentParser(description="Convert STP to OBJ using Gmsh python API")
    parser.add_argument("input", help="Input STP file")
    parser.add_argument("output", nargs='?', help="Output OBJ file")
    parser.add_argument("--scale", type=float, default=0.001, help="Scale factor (default 0.001 for mm to m)")
    
    args = parser.parse_args()
    
    if not args.output:
        base, _ = os.path.splitext(args.input)
        args.output = base + ".obj"

    if not os.path.exists(args.input):
        print(f"Error: Input file {args.input} not found.")
        sys.exit(1)

    print(f"Initializing Gmsh to convert {args.input} -> {args.output}")
    
    gmsh.initialize()
    
    try:
        # Load the file
        gmsh.open(args.input)
        
        # We need to generate a mesh for the geometry to export as OBJ
        # Dimensions: 1 (lines), 2 (surfaces), 3 (volumes)
        # For OBJ containing surface mesh, we need to mesh surfaces.
        print("Generating mesh...")
        
        # Option to set mesh quality or algorithm if needed
        # gmsh.option.setNumber("Mesh.Algorithm", 6) # Frontal-Delaunay for 2D meshes
        
        # Generate 2D mesh (Surface mesh)
        gmsh.model.mesh.generate(2)
        
        # Save to output file
        print(f"Saving to {args.output}...")
        gmsh.write(args.output)
        
    except Exception as e:
        print(f"Error during conversion: {e}")
        sys.exit(1)
    finally:
        gmsh.finalize()

    if args.scale != 1.0:
        print(f"Scaling mesh by {args.scale} using trimesh...")
        try:
            mesh = trimesh.load(args.output, force='mesh')
            mesh.apply_scale(args.scale)
            mesh.export(args.output)
            print("Scaling complete.")
        except Exception as e:
            print(f"Error during scaling: {e}")
            sys.exit(1)
    
    print("Conversion complete.")

if __name__ == "__main__":
    main()
