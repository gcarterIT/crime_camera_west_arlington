use [crime_camera_west_arlington]

select 
	count(*)
from 
	[dbo].[crime_gwynn_oak_landing_1mi_border]
-- 39070


-- find unique lats/lngs and crime counts
--   at those locations
select 
	Latitude,
	Longitude,
	count(*)
from 
	[dbo].[crime_gwynn_oak_landing_1mi_border]
group by 
	Latitude,
	Longitude
order by
	count(*) desc

-- those with counts > 100
--Latitude	Longitude	(No column name)
--39.3575	-76.7043	370
--39.319	-76.665		216
--39.3317	-76.6904	215
--39.3444	-76.6854	195
--39.3491	-76.676		191
--39.3309	-76.6943	180
--39.3448	-76.7014	169
--39.3477	-76.6993	168
--39.3453	-76.6815	166
--39.3562	-76.7025	162
--39.3478	-76.6687	145
--39.3512	-76.6954	141
--39.3518	-76.6834	136
--39.3421	-76.6824	123
--39.3483	-76.6748	119
--39.3396	-76.6665	113
--39.3462	-76.6806	109
--39.3562	-76.7027	105
--39.3507	-76.6946	101

-- just curious about this one
--Latitude	Longitude	(No column name)
--39.3575	-76.7043	370

select
	*
from
	[dbo].[crime_gwynn_oak_landing_1mi_border]
where 
	Latitude = 39.3575
	and 
	Longitude = -76.7043


select
	[Description],
	count(*)
from
	[dbo].[crime_gwynn_oak_landing_1mi_border]
where 
	Latitude = 39.3575
	and 
	Longitude = -76.7043
group by
	[Description]
order by
	count(*) desc

--Description		(No column name)
--LARCENY				283
--COMMON ASSAULT		22
--LARCENY FROM AUTO		17
--AGG. ASSAULT			12
--AUTO THEFT			10
--ROBBERY - COMMERCIAL	10
--ROBBERY - STREET		8
--BURGLARY				4
--HOMICIDE				2
--SHOOTING				2
