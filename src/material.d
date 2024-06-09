module material;
@safe nothrow:

import color;
import hittable;
import random;
import ray;
import vec3;

interface Material
{
    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const;
}

class Lambertian: Material
{
    private Color albedo;

    this(Color albedo)
    {
        this.albedo = albedo;
    }

    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const
    {
        auto scatterDir = rec.normal + randomUnitVec3f();
        if (scatterDir.isZero())
            scatterDir = rec.normal;

        auto scattered = new Ray(rec.p, scatterDir);
        attenuation = albedo;
        return scattered;
    }
}

class Metal: Material
{
    private Color albedo;

    this(Color albedo)
    {
        this.albedo = albedo;
    }

    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const
    {
        const reflected = reflect(rayIn.direction, rec.normal);
        auto scattered = new Ray(rec.p, reflected);
        attenuation = albedo;
        return scattered;
    }

    private static Vec3f reflect(Vec3f v, Vec3f n)
    {
        return v - 2.0f * v.dot(n) * n;
    }
}
