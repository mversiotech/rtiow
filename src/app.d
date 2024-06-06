import std.stdio;

import color;

enum
{
    imageWidth  = 256,
    imageHeight = 256
}

void main()
{
    auto buffer = new ColorBuffer(imageWidth, imageHeight);

    for (int y = 0; y < imageHeight; y++)
    {
        const g = cast(float) y / cast(float) imageHeight;

        for (int x = 0; x < imageWidth; x++)
        {
            const r = cast(float) x / cast(float) imageWidth;

            buffer.setPixel(x, y, Color(r, g, 0.0f));
        }
    }

    buffer.savePNG("output.png");
}
