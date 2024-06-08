module interval;
@safe @nogc nothrow:

struct Interval
{
    const float min;
    const float max;

    static const Interval empty = Interval(float.infinity, -float.infinity);
    static const Interval universe = Interval(-float.infinity, float.infinity);

    float size() const
    {
        return max - min;
    }

    bool contains(float x) const
    {
        return x >= min && x <= max;
    }

    bool surrounds(float x) const
    {
        return x > min && x < max;
    }

    float clamp(float x) const
    {
        if (x < min)
            return min;

        if (x > max)
            return max;

        return x;
    }
}
