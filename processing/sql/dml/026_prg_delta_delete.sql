delete from prg.delta_new prg
using osm_adr osm
where st_dwithin(prg.geom, st_transform(osm.geom, 2180), 40) and prg.nr_standaryzowany = osm.nr ;
analyze prg.delta_new;
