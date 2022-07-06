-- restrict area to a 1mi x 1mi square with cctv in center

use [crime_camera_west_arlington]

select
	*
into
	crime_1mile_square2
from
	[dbo].[crime_data_draft2]
where
	--# top-left:     39.345848, -76.694313
	--# top-right:    39.345848, -76.675429
	--# bottom-left:  39.331448, -76.694313
	--# bottom-right: 39.331448, -76.675429

	([Latitude] between 39.331448 and 39.345848)
	and
	([Longitude] between -76.694313 and -76.675429)