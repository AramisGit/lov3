# lov3
A lightweight 3D implementation of the [love2D](https://love2d.org/) engine using shadow volumes.

![alt text](example_b.png "example")

This is just a hobby project, mostly to test the feasibility of shadow volumes. Anyone is free to do what they like with this.

This requires love2D, and the entirety of the "3d-ification" of the engine lives in the single lov3.lua file.

Below is a simple example scene where some of the cubes act as differently coloured point lights (all lights are point lights in this implementation).
Below that is the same scene with the shadows of each respective light as wireframes.

![alt text](example.png "with shadows") ![alt text](example_with_volumes.png "with debug volumes")

A comment from inside the lov3.lua file that describes the goal of this project:

The idea is that for our shadowing technique, we want to do shadow volumes. This is opposed to the standard shadowing method of 
    shadow-mapping.

The basic premise is that for each light we want producing shadows, and each object in our scene we want shadowed, we'll be 
    producing a "volume" that describes the 3D region where the light will not reach. It exact terms, we'll be generating geometry
    that describes the "umbra" of the occluding body with respect to the particular light source.
    
To achieve this we'll need a regular buffer, a depth buffer, and a stencil buffer.
    
We'll initially render the objects of our scene to the regular buffer as if no lights existed, (i.e. everything is "shadowed"), then 
    we'll render the shadow volumes produced from the objects lit by our first light to the depth and stencil buffers, and broadly speaking, 
    use the interaction of these two buffers to 'slice' out a version of our regular buffer that is 'allowed' to be lit, then render our objects
    in that "sliced" regular buffer, lit accordingly. Then we'll move onto the next light, additively blending the results, light by light, 
    until all the lights in our scene have made their contribution.

Now how do we generate a shadow volume? Well, it'll basically look like the object itself, extruded in the direction away from 
    the light. This extrusion will occur at the edges of the object that form it's silhouette. Our objects are made of triangles, 
    so our silhouette will be the set of edges that are shared by both a "lit" triangle, and an "unlit" triangle. And we can figure that 
    out by checking the normal of each triangle against the light's direction.

We've hopefully included some basic primitives in this project. I'll use the cube as an example. A cube has 6 faces, 8 corners. 
    Now those faces are squares, which our GPU doesn't know how to draw. It only knows triangles, so we have to draw 2 for each square.
    So that's 12 triangles. And with each triangle having 3 points, our mesh will have 36 vertices.

For silhouette determination, we care about the edges of our mesh, so those 12 triangles also have 3 edges each, so that's also 36 edges. 
    But, if we're studious, we'll recognise that any particular edge belongs to both of the 2 triangles it joins, so, when we boil it down, 
    we only have 18 "unique" edges, where, for any particular edge made of points (a, b), there is an identical edge made of points (b, a). 
    Their commutative. We'll be taking advantage of this when we determine our silhouette.

Now, as an aside, you might whisper, "Hey! Big guy! Cubes only have 12 edges!" This is true... if you know what a square is! Remember, the
    GPU is a triangle-based lifeform. And so with each square face being made of 2 triangles, there's an additional 6 invisible "edges" which 
    diagonally join those 2 triangles on each face. These "edges" that aren't quite edges might actually cause us some headaches later. We'll
    probably have to figure out a way to exclude them...

Anyway, we basically have 2 options here:
        1. We pack all that information into love2d's mesh vertex buffer, which will probably contain the original objects vertices, 
            and a bunch more to account for whatever possible "extrusion" we could be generating. Then over in shader-land, use the 
            information to actually move the vertices where we want them. This'll mean a pretty big mesh, as we'll need to account for any
            possible extrusion, and each vertex needs to know a fair amount of context about the edge determination as a whole. This might be
            possible, but thats alot of information. Although, the GPU wouldn't blink an eye at performing these calculations. We could even 
            investigate writing a geomtery shader for this purpose. But that's a whole other kettle of fish.
        2. Keep the mesh smaller, or even seperate the regular mesh and the 'shadow-mesh', and do it back here in CPU-land, and use 
            the FFI library to talk to Lua's big brother C, and manipulate some memory-contiguous vertex buffers so the CPU doesn't blink 
            too much of an eye either.

I've gone with option 2.

Firstly, we're going to wrap a 3D-ified love:mesh (we've added a z-coord and a normal) into our own mesh container (which we might 
    call "mesh3", or something), where we'll keep an array of the vertex x,y,z positions (so we can do some fast copies, as we don't 
    have direct access to the love:mesh vertex buffer) and references to which edge they belong to (probably just use some indices), so 
    that when we're iterating through the buffer, we'll know that if we're at an edge described by (vertex[a], vertex[b]), we're also at 
    the edge (vertex[b], vertex[a]).

A draw-back of keeping our own array of vertex positions is that this assumes the mesh vertices will stay exactly where they are 
    (in local space), for the lifetime of the mesh. If we deform our mesh, they won't, and our shadows won't align with their respective 
    object when it does so. The fix, ofcourse, is to not have our own vertex buffer (and rely on love2d's mesh.getVertex, which is a 
    little slower than I'd like) or, anytime we update our mesh's vertices, we update our vertex buffer too. We might be able to pre-empt 
    this behaviour with a flag like OpenGL's 'dynamic', and if it is 'dynamic', we use getVertex() instead'. Or something like that.
    What we really want ofcourse is direct access to the vert buffer, but as of love2D 11.5, we don't. We'll see.

As for our edges, they shouldn't really change throughout the lifetime of our mesh, regardless of any deformations. This is good.

Saying all this, I'm realising we could maybe ONLY keep our own internal buffer, and change that to our own desire, then set the love:mesh 
    as we change IT, essentially inverting the source of truth from love:mesh to our own buffer. That might be a way forward. We'll see!
