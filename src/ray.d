module ray;
@safe:

import vec3;

class Ray
{
    const Point3f origin;
    const Vec3f direction;

    this(Point3f origin, Vec3f direction)
    {
        assert(!direction.isZero());

        this.origin = origin;
        this.direction = direction;
    }

    Point3f at(float t) const
    {
        return origin + t * direction;
    }
}
