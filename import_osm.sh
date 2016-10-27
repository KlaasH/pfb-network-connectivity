#!/usr/bin/env bash

cd `dirname $0`

NB_POSTGRESQL_HOST="${NB_POSTGRESQL_HOST:-127.0.0.1}"
NB_POSTGRESQL_DB="${NB_POSTGRESQL_DB:-pfb}"
NB_POSTGRESQL_USER="${NB_POSTGRESQL_USER:-gis}"
NB_POSTGRESQL_PASSWORD="${NB_POSTGRESQL_PASSWORD:-gis}"
NB_OSMFILE="${NB_OSMFILE:-/vagrant/data/neighborhood.osm}"

# drop old tables
echo 'Dropping old tables'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_ways_intersections;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_relations_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_way_types;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_ways_vertices_pgr;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_relations_ways;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS scratch.neighborhood_cycwys_osm_way_types;"

# import the osm with highways
osm2pgrouting \
  -f $NB_OSMFILE \
  -h $NB_POSTGRESQL_HOST \
  --dbname ${NB_POSTGRESQL_DB} \
  --username ${NB_POSTGRESQL_USER} \
  --schema received \
  --prefix neighborhood_ \
  --conf ./mapconfig_highway.xml \
  --clean

# import the osm with cycleways that the above misses (bug in osm2pgrouting)
osm2pgrouting \
  -f $NB_OSMFILE \
  -h $NB_POSTGRESQL_HOST \
  --dbname ${NB_POSTGRESQL_DB} \
  --username ${NB_POSTGRESQL_USER} \
  --schema scratch \
  --prefix neighborhood_cycwys_ \
  --conf ./mapconfig_cycleway.xml \
  --clean

# rename a few tables
echo 'Renaming tables'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_ways_vertices_pgr RENAME TO neighborhood_ways_intersections;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_ways_intersections RENAME CONSTRAINT vertex_id TO neighborhood_vertex_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_nodes RENAME TO neighborhood_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_osm_nodes RENAME CONSTRAINT node_id TO neighborhood_node_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_relations RENAME TO neighborhood_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_way_classes RENAME TO neighborhood_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_osm_way_classes RENAME CONSTRAINT osm_way_classes_pkey TO neighborhood_osm_way_classes_pkey;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_way_tags RENAME TO neighborhood_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.osm_way_types RENAME TO neighborhood_osm_way_types;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE received.neighborhood_osm_way_types RENAME CONSTRAINT osm_way_types_pkey TO neighborhood_osm_way_types_pkey;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_ways_vertices_pgr RENAME CONSTRAINT vertex_id TO neighborhood_vertex_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_nodes RENAME TO neighborhood_cycwys_osm_nodes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_osm_nodes RENAME CONSTRAINT node_id TO neighborhood_node_id;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_relations RENAME TO neighborhood_cycwys_osm_relations;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_way_classes RENAME TO neighborhood_cycwys_osm_way_classes;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_osm_way_classes RENAME CONSTRAINT osm_way_classes_pkey TO neighborhood_osm_way_classes_pkey;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_way_tags RENAME TO neighborhood_cycwys_osm_way_tags;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.osm_way_types RENAME TO neighborhood_cycwys_osm_way_types;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE scratch.neighborhood_cycwys_osm_way_types RENAME CONSTRAINT osm_way_types_pkey TO neighborhood_osm_way_types_pkey;"

# import full osm to fill out additional data needs
# not met by osm2pgrouting

# drop old tables
echo 'Dropping old tables'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_line;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_point;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_polygon;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "DROP TABLE IF EXISTS received.neighborhood_osm_full_roads;"

# import
osm2pgsql \
  --host "${NB_POSTGRESQL_HOST}" \
  --username ${NB_POSTGRESQL_USER} \
  --port 5432 \
  --create \
  --database "${NB_POSTGRESQL_DB}" \
  --prefix "neighborhood_osm_full" \
  --proj 2249 \
  --style ./pfb.style \
  "${NB_OSMFILE}"

# move the full osm tables to the received schema
echo 'Moving tables to received schema'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_line SET SCHEMA received;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_point SET SCHEMA received;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_polygon SET SCHEMA received;"
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} \
  -c "ALTER TABLE generated.neighborhood_osm_full_roads SET SCHEMA received;"

# process tables
echo 'Updating field names'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./prepare_tables.sql
echo 'Setting values on road segments'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./one_way.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./functional_class.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./paths.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./speed_limit.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./width_ft.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./lanes.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./park.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./bike_infra.sql
echo 'Setting values on intersections'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./legs.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./signalized.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stops.sql
echo 'Calculating stress'
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_motorway-trunk.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_primary.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_secondary.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_tertiary.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_residential.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_living_street.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_track.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_path.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_one_way_reset.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_motorway-trunk_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_primary_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_secondary_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_tertiary_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_lesser_ints.sql
psql -h $NB_POSTGRESQL_HOST -U ${NB_POSTGRESQL_USER} -d ${NB_POSTGRESQL_DB} -f ./stress_link_ints.sql
