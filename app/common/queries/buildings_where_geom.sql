with
data as (
    select
        row_number() over() as way_id,
        geom_4326,
        GeometryType(geom_4326) geom_type,
        jsonb_strip_nulls(jsonb_build_object(
           'building', building,
           'amenity', amenity,
           'man_made', man_made,
           'leisure', leisure,
           'historic', historic,
           'tourism', tourism,
           'building:levels', building_levels,
           'source', 'www.geoportal.gov.pl'
        )) tags
    from bdot_buildings b
    left join exclude_bdot_buildings ex on b.lokalnyid=ex.id
    where 1=1
        and ex.id is null
        and b.geom_4326 && ST_GeomFromGeoJSON( %(geojson_geometry)s )
        and st_intersects(b.geom_4326, ST_GeomFromGeoJSON( %(geojson_geometry)s ))
    limit 50000
),
points as (
    select
        way_id,
        ST_DumpPoints(geom_4326) dp
    from data
),
outer_rings as (
    select
        way_id,
        array_agg(ARRAY[st_y((dp).geom), st_x((dp).geom)]) as outer_ring
    from points
    where 1=1
        and (dp).path[1] = 1
    group by way_id
),
inner_rings_temp as (
    select
        way_id,
        array_agg(ARRAY[st_y((dp).geom), st_x((dp).geom)]) as inner_ring
    from points
    where 1=1
        and (dp).path[1] > 1
    group by way_id, (dp).path[1]
),
inner_rings_final as (
    select
        way_id,
        jsonb_agg(inner_ring) as inner_rings -- inner rings have different dimensionality so we can't use regular postgresql arrays
    from inner_rings_temp
    group by way_id
)
select
    geom_type,
    tags,
    outer_ring,
    coalesce(inner_rings, '[]'::jsonb) inner_rings
from data
inner join outer_rings using(way_id)
left join inner_rings_final using(way_id)
;