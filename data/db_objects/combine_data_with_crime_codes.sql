/****** Script for SelectTopNRows command from SSMS  ******/
SELECT RowID  
	  ,[X]
      ,[Y]
      ,[CrimeDateTime]
      ,[CrimeCode]
      ,[Location]
      ,[Description]
      ,[Inside_Outside]
      -- ,c1ms.[Weapon]
	  -- cc.WEAPON appears more complete, so we'll only use this
	  ,cc.[WEAPON]
      ,[Post]
      ,[Gender]
      ,[Age]
      ,[Race]
      ,[Ethnicity]
      ,[District]
      ,[Neighborhood]
      ,[Latitude]
      ,[Longitude]
      ,[GeoLocation]
      ,[Premise]
      ,[VRIName]
      ,[Total_Incidents]
      ,[Shape]
	  ,[TYPE]
	  -- this has more detail
	  ,[NAME]
	  -- this lacks detail, so we'll ignore
	  --,[NAME_COMBINE]
	  ,[CLASS]
	  ,[VIOLENT_CR]
	  ,[VIO_PROP_CFS]
into
	crime_1mile_square3
  FROM [crime_camera_west_arlington].[dbo].[crime_1mile_square2] c1ms
		left join [crime_camera_west_arlington].[dbo].[CRIME_CODES] cc
		on
			c1ms.CrimeCode = cc.CODE