module random;
@safe:

import vec3;

/// randomVec3f returns a Vec3f with random components within the given range
Vec3f randomVec3f(float min, float max)
{
    import std.random : uniform;

    const x = uniform(min, max);
    const y = uniform(min, max);
    const z = uniform(min, max);

    return Vec3f(x, y, z);
}

/// randomUnitVec3f returns a Vec3f with random components and length 1
Vec3f randomUnitVec3f()
{
    // we could use just any random vector and return it scaled to unit length,
    // but that would be a non-uniform distribution. To ensure uniformity we
    // require that the generated vector lies within a unit sphere.
    while (true)
    {
        const v = randomVec3f(-1, 1);
        if (v.lengthSquared() <= 1.0f)
            return v.unit();
    }
}

/// randomVec3fOnHemisphere returns a random Vec3f with the same direction
/// as the given normal. The returned vector will have a length of 1.
Vec3f randomVec3fOnHemisphere(Vec3f normal)
{
    const v = randomUnitVec3f();
    if (v.dot(normal) > 0)
        return v;
    else
        return -v;
}
