local lov3_shaders = {}

--- Built-In love2D shader variables ---
--- 
--- GLOBAL ---
---
--- mat4 TransformMatrix: The transformation matrix affected by love.graphics.translate and friends. 
---                        Note that automatically batched vertices are transformed on the CPU, and their TransformMatrix will be an identity matrix.
---
--- mat4 ProjectionMatrix: The orthographic projection matrix.
--- 
--- mat4 TransformProjectionMatrix: The combined transform and projection matrices. 
---                                 Used as the transform_projection argument to the vertex shader position function.
--- 
--- vec4 VaryingTexCoord: The interpolated per-vertex texture coordinate. 
---                       Automatically set to the value of VertexTexCoord in the vertex shader before the position function is called. 
---                       Used as the texture_coords argument to the pixel shader effect function.
--- 
--- vec4 VaryingColor: The interpolated per-vertex color. 
---                    Automatically set to the value of ConstantColor * gammaCorrectColor(VertexColor) in the vertex shader before the position function is called.
--- 
--- vec4 love_screenSize: The width and height of the screen (or canvas) currently being rendered to, stored in the x and y components of the variable. 
---                       The z and w components are used internally by LÖVE.
--- 
--- VERTEX ---
--- 
--- vec4 VertexPosition: The pre-transformed position of the vertex. 
---                      Used as the vertex_position argument to the vertex shader position function.
--- 
--- vec4 VertexTexCoord: The texture coordinate of the vertex.
---                      Meshes allow for custom texture coordinates.
--- 
--- vec4 VertexColor: The color of the vertex, sprite, or text character if a Mesh, SpriteBatch, or Text object with per-vertex colors is drawn.
---                   It does not have gamma-correction applied.
--- 
--- vec4 ConstantColor: The global color set with love.graphics.setColor. 
---                     If global gamma-correction is enabled, it will already be gamma-corrected. 
---
--- FRAG ---
---
--- vec4 array love_Canvases[]: Array used to set per-canvas pixel colors when multiple canvases are set with love.graphics.setCanvas and the void effect variant is used instead of the vec4 effect variant of the function. 
---                             Writable in the pixel shader when the void effect variant is used.
---
--- vec2 love_PixelCoord: Coordinates of the pixel on screen. 
---                       The same as screen_coords passed to the vec4 effect Shader function
---

-- The standard shader with required lov3 matrices
lov3_shaders.unlit =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform vec4 colour;

    #ifdef VERTEX
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        return projection_matrix * view_matrix * TransformMatrix * vertex_position;
    }
    #endif
    #ifdef PIXEL
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color * colour;
    }
    #endif
]]

-- ambient
lov3_shaders.ambient =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform float intensity = 0.1;
    uniform vec4 colour;
    
    #ifdef VERTEX
    attribute vec3 VertexNormal;
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        return projection_matrix * view_matrix * TransformMatrix * vertex_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * vec4(color.rgb * colour.rgb * intensity, color.a);
    }
    #endif
]]

-- Gouraud shaded diffuse (vertex interpolated lighting)
lov3_shaders.diffuse_gouraud =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform mat4 inverse_model_matrix;
    uniform vec3 light_position;
    uniform float light_diffuse = 1;
    uniform float light_ambient = 0.1;
    
    #ifdef VERTEX
    attribute vec3 VertexNormal;
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        mat3 normal_matrix = mat3(transpose(inverse_model_matrix));

        vec3 norm = normalize(mat3(normal_matrix) * VertexNormal);
        vec3 vert_pos = vec3(TransformMatrix * vertex_position);
        vec3 light_dir = normalize(light_position - vert_pos);

        float diffuse_intensity = max(dot(norm, light_dir) * light_diffuse, 0.0);

        vec4 diffuse_color = vec4(vec3(VertexColor) * diffuse_intensity, VertexColor.a);
        vec4 ambient_color = vec4(vec3(VertexColor) * light_ambient, VertexColor.a);

        VaryingColor = diffuse_color + ambient_color;

        return projection_matrix * view_matrix * TransformMatrix * vertex_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color;
    }
    #endif
]]

-- Phong shaded diffuse (fragment interpolated lighting)
lov3_shaders.diffuse_phong =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform mat4 inverse_model_matrix;
    uniform vec3 light_position;
    uniform float light_diffuse = 1;
    uniform float light_ambient = 0.1;

    varying vec3 frag_pos;
    varying vec3 norm;

    #ifdef VERTEX
    attribute vec3 VertexNormal;
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        mat3 normal_matrix = mat3(transpose(inverse_model_matrix));

        norm = normalize(normal_matrix * VertexNormal);
        frag_pos = vec3(TransformMatrix * vertex_position);

        return projection_matrix * view_matrix * TransformMatrix * vertex_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(tex, texture_coords);

        vec3 light_dir = normalize(light_position - frag_pos);

        float diffuse_intensity = max(dot(norm, light_dir) * light_diffuse, 0.0);

        vec4 diffuse_color = vec4(vec3(color) * diffuse_intensity, color.a);
        vec4 ambient_color = vec4(vec3(color) * light_ambient, color.a);

        vec4 color_unlit = texcolor * color;

        vec4 color_lit = vec4(color_unlit.rgb * (light_ambient + diffuse_intensity), color_unlit.a);

        return color_lit;
    }
    #endif
]]

-- Gouraud shaded specular (vertex interpolated lighting)
lov3_shaders.specular_gouraud =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform mat4 inverse_model_matrix;
    uniform vec3 light_position;
    uniform float light_ambient = 0.05;
    uniform float light_diffuse = 1;
    uniform float light_specular = 32;

    #ifdef VERTEX
    attribute vec3 VertexNormal;
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        mat3 normal_matrix = mat3(transpose(inverse_model_matrix));

        vec3 view_norm = normalize(mat3(view_matrix) * normal_matrix * VertexNormal);
        vec3 view_frag_pos = vec3(view_matrix * TransformMatrix * vertex_position);
        vec3 view_light_pos = vec3(view_matrix * vec4(light_position, 1));

        vec3 light_dir = normalize(view_light_pos - view_frag_pos);
        vec3 reflection = normalize(-reflect(light_dir, view_norm));
        vec3 eye = normalize(-view_frag_pos);

        float diffuse_intensity = max(dot(view_norm, light_dir) * light_diffuse, 0.0);
        float specular_intensity = pow(max(dot(reflection, eye), 0.0), light_specular);

        VaryingColor = vec4(VertexColor.rgb * (light_ambient + diffuse_intensity + specular_intensity), VertexColor.a);

        return projection_matrix * view_matrix * TransformMatrix * vertex_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color;
    }
    #endif
]]
 
-- Phong shaded specular (fragment interpolated lighting)
lov3_shaders.specular_phong =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform mat4 inverse_model_matrix;
    uniform vec3 light_position;
    uniform float ambient_intensity = 0;
    uniform float diffuse_intensity = 0.5;
    uniform float specular_intensity = 0.5;
    uniform float specular_coefficient = 8;
    uniform float intensity = 1;
    uniform float attenuation = 10;
    uniform vec4 light_color;
    uniform vec4 colour;

    varying vec3 view_frag_pos;
    varying vec3 view_norm;
    varying vec3 view_light_pos;

    #ifdef VERTEX
    attribute vec3 VertexNormal;
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        mat3 normal_matrix = mat3(transpose(inverse_model_matrix));

        view_norm = normalize(mat3(view_matrix) * normal_matrix * VertexNormal);
        view_frag_pos = vec3(view_matrix * TransformMatrix * vertex_position);
        view_light_pos = vec3(view_matrix * vec4(light_position, 1));

        return projection_matrix * view_matrix * TransformMatrix * vertex_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 vertex_color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(tex, texture_coords);

        vec3 delta_light_pos = view_light_pos - view_frag_pos;
        vec3 light_dir = normalize(delta_light_pos);
        vec3 reflection = normalize(reflect(-light_dir, view_norm));
        vec3 eye = normalize(-view_frag_pos);

        float ambient_component = ambient_intensity;
        float diffuse_component = max(dot(view_norm, light_dir) * diffuse_intensity, 0.0);
        float specular_component = pow(max(dot(reflection, eye), 0.0), specular_coefficient) * specular_intensity;
        float range_component = max((attenuation - length(delta_light_pos))/attenuation, 0.0);

        float strength = (ambient_component + diffuse_component + specular_component) * intensity * range_component;

        return texcolor * vec4((vertex_color.rgb * colour.rgb * light_color.rgb) * strength, colour.a);
    }
    #endif
]]

-- Shader used to render shadow volume meshes.
lov3_shaders.shadow_volume =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform vec3 light_position;
    uniform float attenuation = 20;
    
    #ifdef VERTEX
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        vec4 world_position = TransformMatrix * vec4(vertex_position.xyz, 1);
        vec3 light_delta = world_position.xyz - light_position;
        vec3 light_dir = normalize(light_delta);

        //float angle_delta = dot(light_delta, vertex_position.xyz);

        float distance = max(attenuation - length(light_delta), 0.0);

        world_position = world_position + vec4(light_dir * (distance * vertex_position.w + 0.01), 0);
        
        return projection_matrix * view_matrix * world_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        return color;
    }
    #endif


]]

-- Shader used to produce and render hacky shadow volumes from phong shaded meshes.
lov3_shaders.shadow_volume_simple =
[[
    uniform mat4 view_matrix;
    uniform mat4 projection_matrix;
    uniform vec3 light_position;
    uniform mat4 inverse_model_matrix;
    uniform float attenuation = 20;
    
    #ifdef VERTEX
    attribute vec3 VertexNormal;
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        mat3 normal_matrix = mat3(transpose(inverse_model_matrix));
        vec3 normal = normalize(normal_matrix * VertexNormal);
        vec4 world_position = TransformMatrix * vertex_position;
        vec3 light_delta = world_position.xyz - light_position;
        vec3 light_dir = normalize(light_delta);
        float is_lit = floor(dot(normal, light_dir) + 1);
        float distance = max(attenuation - length(light_delta), 0.0);

        world_position = world_position + vec4(light_dir * (distance * is_lit + 0.01), 0);

        return projection_matrix * view_matrix * world_position;
    }
    #endif
    
    #ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        return color;
    }
    #endif
]]


lov3_shaders.standard =
[[
    #ifdef VERTEX
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        return transform_projection * vertex_position;
    }
    #endif
    #ifdef PIXEL
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color;
    }
    #endif
]]

lov3_shaders.blur = 
[[
    extern vec2 size;
    extern int samples = 8;
    extern float quality = 1;

    #ifdef VERTEX
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        return transform_projection * vertex_position;
    }
    #endif
    #ifdef PIXEL
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 sum = vec4(0);
        int diff = (samples - 1) / 2;
        vec2 sizeFactor = vec2(2) / size * quality;

        for (int x = -diff; x <= diff; x++)
        {
            for (int y = -diff; y <= diff; y++)
            {
                vec2 offset = vec2(x, y) * sizeFactor;
                sum += Texel(tex, texture_coords + offset);
            }
        }
        
        vec4 result = ((sum / (samples * samples)) + texcolor);
        
        return result;
    }
    #endif
]]


return lov3_shaders