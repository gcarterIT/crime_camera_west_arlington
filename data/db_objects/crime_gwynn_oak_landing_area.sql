-- restrict area to a 1mi x 1mi square with cctv in center

use [crime_camera_west_arlington]

select
	*
into
	crime_gwynn_oak_landing
from
	[dbo].[crime_data_draft2]
where
	-- gwynn oak landing lat/lng corner boundaries, per google earth
	--# top-left:     39.343543, -76.697630
	--# top-right:    39.343543, -76.683136
	--# bottom-left:  39.333413, -76.697630
	--# bottom-right: 39.333413, -76.683136

	([Latitude]  between  39.333413 and 39.343543)
	and
	([Longitude] between -76.697630 and -76.683136)