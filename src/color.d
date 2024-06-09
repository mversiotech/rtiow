/// Module color implements color buffers and related functions
module color;

import gamut;

import interval;
import vec3;

alias Color = Vec3!float;

class ColorBuffer
{
    const int w;
    const int h;

    private ubyte[] data;

    /// Constructs a new color buffer with the given dimensions.
    @safe this(int width, int height)
    {
        assert(width > 0 && height > 0);

        w = width;
        h = height;
        data = new ubyte[3 * w * h];
    }

    @safe void setPixel(int x, int y, Color c)
    {
        assert(x >= 0 && y >= 0 && x < w && y < h);

        const r = linearToGamma(c.x);
        const g = linearToGamma(c.y);
        const b = linearToGamma(c.z);

        const intensity = Interval(0, 0.999f);

        auto pixel = data[3 * (y * w + x) .. $];
        pixel[0] = cast(ubyte) (256.0f * intensity.clamp(r));
        pixel[1] = cast(ubyte) (256.0f * intensity.clamp(g));
        pixel[2] = cast(ubyte) (256.0f * intensity.clamp(b));
    }

    void savePNG(string filename)
    {
        Image img = Image(w, h, PixelType.rgb8);
        img.createViewFromData(data.ptr, w, h, PixelType.rgb8, 3 * w);

        if (!img.saveToFile(ImageFormat.PNG, filename))
            throw new Exception("cannot save PNG: " ~ img.errorMessage().idup());
    }

    private @safe float linearToGamma(float linear)
    {
        import std.math: sqrt;

        if (linear > 0)
            return sqrt(linear);

        return 0.0f;
    }
}
