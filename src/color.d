/// Module color implements color buffers and related functions
module color;

import gamut;
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
        import std.math : floor;

        assert(x >= 0 && y >= 0 && x < w && y < h);

        auto pixel = data[3 * (y * w + x) .. $];
        pixel[0] = cast(ubyte) floor(256.0f * c.x);
        pixel[1] = cast(ubyte) floor(256.0f * c.y);
        pixel[2] = cast(ubyte) floor(256.0f * c.z);
    }

    void savePNG(string filename)
    {
        Image img = Image(w, h, PixelType.rgb8);
        img.createViewFromData(data.ptr, w, h, PixelType.rgb8, 3 * w);

        if (!img.saveToFile(ImageFormat.PNG, filename))
            throw new Exception("cannot save PNG: " ~ img.errorMessage().idup());
    }
}
