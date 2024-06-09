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

class Lambertian : Material
{
    const Color albedo;

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

class Metal : Material
{
    const Color albedo;
    const float fuzz;

    this(Color albedo, float fuzz)
    {
        this.albedo = albedo;
        this.fuzz = (fuzz < 1.0f) ? fuzz : 1.0f;
    }

    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const
    {
        auto reflected = reflect(rayIn.direction, rec.normal).unit();
        reflected += fuzz * randomUnitVec3f();
        auto scattered = new Ray(rec.p, reflected);
        attenuation = albedo;
        if (scattered.direction.dot(rec.normal) > 0)
            return scattered;

        return null;
    }

}

class Dielectric : Material
{
    const float refractionIndex;

    this(float refractionIndex)
    {
        this.refractionIndex = refractionIndex;
    }

    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const
    {
        import std.math : fmin, sqrt;
        import std.random: uniform01;

        attenuation = Color(1.0f, 1.0f, 1.0f);
        float ri = rec.isFront ? (1.0f / refractionIndex) : refractionIndex;

        Vec3f unitDirection = rayIn.direction.unit();
        float cosTheta = fmin(rec.normal.dot(-unitDirection), 1.0f);
        float sinTheta = sqrt(1.0f - cosTheta * cosTheta);

        Vec3f direction;
        if (ri * sinTheta > 1.0f || reflectance(cosTheta, ri) > uniform01())
            direction = reflect(unitDirection, rec.normal);
        else
            direction = refract(unitDirection, rec.normal, ri);

        return new Ray(rec.p, direction);
    }
}

private Vec3f reflect(Vec3f v, Vec3f n)
{
    return v - 2.0f * v.dot(n) * n;
}

private Vec3f refract(Vec3f uv, Vec3f n, float etaiOverEtat)
{
    import std.math : fabs, fmin, sqrt;

    float cosTheta = fmin(n.dot(-uv), 1.0f);
    Vec3f rOutPerp = etaiOverEtat * (uv + cosTheta * n);
    Vec3f rOutParallel = -sqrt(fabs(1.0 - rOutPerp.lengthSquared())) * n;

    return rOutPerp + rOutParallel;
}

private float reflectance(float cosine, float refractionIndex)
{
    import std.math: pow;

    float r0 = (1.0f - refractionIndex) / (1.0f + refractionIndex);
    r0 = r0 * r0;
    return r0 + (1.0f - r0) * pow((1.0f - cosine), 5);
}
