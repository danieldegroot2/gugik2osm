create index if not exists prg_pa_hashed_geom on prg.pa_hashed using gist (geom);
analyze prg.pa_hashed;
