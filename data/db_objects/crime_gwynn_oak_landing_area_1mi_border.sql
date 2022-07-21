-- restrict area to a 1mi x 1mi square with cctv in center

use [crime_camera_west_arlington]

select
	*
into
	crime_gwynn_oak_landing_1mi_border
from
	[dbo].[crime_data_draft2]
where
	-- gwynn oak landing lat/lng 1 mile border corner boundaries, per google earth
	--# top-left:     39.357942, -76.664345
	--# top-right:    39.357942, -76.716529
	--# bottom-left:  39.318873, -76.664345
	--# bottom-right: 39.318873, -76.716529

	([Latitude]  between  39.318873 and 39.357942)
	and
	([Longitude] between -76.716529 and -76.664345)