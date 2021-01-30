drop table if exists prg.pa_hashed;
create table prg.pa_hashed as
select
    md5(concat(lower(prg.teryt_msc), lower(coalesce(prg.osm_ulica, prg.teryt_ulica, '')), prg.nr)) hash,
    lokalnyid,
    gml geom
from prg.pa prg
join teryt.simc on prg.teryt_simc = simc.sym
left join exclude_prg e on lokalnyid = e.id
where
    prg.teryt_msc is not null
    and not (prg.teryt_ulic is null and prg.ul is not null)
    and not (simc.rm like '9%' and prg.teryt_ulica is null)
    and e.id is null
;
