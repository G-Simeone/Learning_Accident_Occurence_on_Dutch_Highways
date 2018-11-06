--- This script links each hectopoint to the hectokey in front and behind it 
--- NOTE: This table is not currently being used but if we were able to fix the current problems with it, would be very useful

--- Schema: rws_clean

--- Tables

--- 	rws_clean.hectopunten_network: for each hectopuen, shows (1) the hectokey,
---			(2) the hectokey of the hectopunten ahead of the current hectopunten in terms of traffic flow and 
---			(3) tthe hectokey of the hectopunten behind the current hectopunten in terms of traffic flow and 
create table rws_clean.network (
        key1 varchar, 
        key2 varchar
);

--PROBLEM: can't connect roads that connect through off ramps?
insert into rws_clean.network
select 
	h1.hectokey as key1, 
	h2.hectokey as key2
from 
	rws_clean.hectopunten as h1
left join lateral (
	--lateral so that we can do distance calcs for each hectopunten 
	select *
	from rws_clean.hectopunten as h
	where h1.hectokey <> h.hectokey --not the same point
		and h1.road_num = h.road_num --on same road
		and (h1.road_dir = h.road_dir --going same direction
			or (h1.road_dir is null and h.road_dir is null))
		and (h1.road_type = h.road_type --same road type
			or (h1.road_type is null and h.road_type is null))
		--hecto increasing or decreasing as appropriate for direction
		and ((h1.road_dir = 'Li' and  h1.hecto > h.hecto) 
			or (h1.road_dir = 'Re' and  h1.hecto < h.hecto))
	--order by distance and selecting the closest one
	order by ST_Distance(ST_MakePoint(h1.lat,h1.long),ST_MakePoint(h.lat,h.long)) asc
	limit 1
) as h2
on true;