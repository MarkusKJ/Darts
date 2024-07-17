shader_type spatial;

uniform vec4 water_color : source_color = vec4(0.04, 0.38, 0.88, 1.0);
uniform vec4 water_color2 : source_color = vec4(0.04, 0.35, 0.78, 1.0);
uniform vec4 foam_color : source_color = vec4(0.8125, 0.9609, 0.9648, 1.0);
uniform float distortion_speed : hint_range(0.1, 5.0) = 2.0;
uniform vec2 tile = vec2(5.0, 5.0);
uniform float height : hint_range(0.1, 5.0) = 2.0;
uniform vec2 wave_size = vec2(2.0, 2.0);
uniform float wave_speed : hint_range(0.1, 5.0) = 1.5;

const float M_2PI = 6.283185307;
const float M_6PI = 18.84955592;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
    int octaves = 6;
    float amplitude = 0.5;
    float frequency = 3.0;
    float value = 0.0;
    
    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

float circ(vec2 pos, vec2 c, float s) {
    c = abs(pos - c);
    c = min(c, 1.0 - c);

    return smoothstep(0.0, 0.002, sqrt(s) - sqrt(dot(c, c))) * -1.0;
}

float waterlayer(vec2 uv) {
    uv = mod(uv, 1.0);
    
    float ret = 1.0;
    ret += circ(uv, vec2(0.37378, 0.277169), 0.0268181);
    ret += circ(uv, vec2(0.0317477, 0.540372), 0.0193742);
    ret += circ(uv, vec2(0.430044, 0.882218), 0.0232337);
    // Add more circ() calls here as needed
    return max(ret, 0.0);
}

vec3 water(vec2 uv, vec3 cdir, float iTime) {
    uv *= vec2(0.25);
    uv += fbm(uv) * 0.2;

    vec2 a = 0.025 * cdir.xz / cdir.y;
    float h = sin(uv.x + iTime);
    uv += a * h;
    h = sin(0.841471 * uv.x - 0.540302 * uv.y + iTime);
    uv += a * h;
    
    float d1 = mod(uv.x + uv.y, M_2PI);
    float d2 = mod((uv.x + uv.y + 0.25) * 1.3, M_6PI);
    d1 = iTime * 0.07 + d1;
    d2 = iTime * 0.5 + d2;
    vec2 dist = vec2(
        sin(d1) * 0.15 + sin(d2) * 0.05,
        cos(d1) * 0.15 + cos(d2) * 0.05
    );
    
    vec3 ret = mix(water_color.rgb, water_color2.rgb, waterlayer(uv + dist.xy));
    ret = mix(ret, foam_color.rgb, waterlayer(vec2(1.0) - uv - dist.yx));
    return ret;
}

void vertex() {
    float time = TIME * wave_speed;
    vec2 uv = UV * wave_size;
    float d1 = mod(uv.x + uv.y, M_2PI);
    float d2 = mod((uv.x + uv.y + 0.25) * 1.3, M_6PI);
    d1 = time * 0.07 + d1;
    d2 = time * 0.5 + d2;
    vec2 dist = vec2(
        sin(d1) * 0.15 + sin(d2) * 0.05,
        cos(d1) * 0.15 + cos(d2) * 0.05
    );
    VERTEX.y += dist.y * height;
}

void fragment() {
    vec2 uv = UV;
    ALBEDO = water(uv * tile, vec3(0, 1, 0), TIME * distortion_speed);
}