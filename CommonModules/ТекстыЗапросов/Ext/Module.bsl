Функция РазмерыТаблиц() Экспорт
	
	Возврат "SELECT 
		|	a2.name AS [ИмяТаблицыSQL],
		|	a1.rows as [КоличествоСтрок],
		|	(a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved,
		|	a1.data * 8 AS [РазмерДанных],
		|	(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS [РазмерИндекса]
		|FROM
		|	(SELECT 
		|		ps.object_id,
		|		SUM (
		|			CASE
		|				WHEN (ps.index_id < 2) THEN row_count
		|				ELSE 0
		|			END
		|			) AS [rows],
		|		SUM (ps.reserved_page_count) AS reserved,
		|		SUM (
		|			CASE
		|				WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
		|				ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
		|			END
		|			) AS data,
		|		SUM (ps.used_page_count) AS used
		|	FROM sys.dm_db_partition_stats ps
		|	GROUP BY ps.object_id) AS a1
		|LEFT OUTER JOIN 
		|	(SELECT 
		|		it.parent_id,
		|		SUM(ps.reserved_page_count) AS reserved,
		|		SUM(ps.used_page_count) AS used
		|	 FROM sys.dm_db_partition_stats ps
		|	 INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
		|	 WHERE it.internal_type IN (202,204)
		|	 GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
		|INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id ) 
		|INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
		|WHERE a2.type <> N'S' and a2.type <> N'IT' and a1.rows>0
		|ORDER BY reserved desc";
		
КонецФункции

Функция СписокВсехТаблиц() Экспорт
	Возврат "SELECT DISTINCT 
		|	a2.name AS [ИмяТаблицыSQL]
		|FROM
		|	sys.all_objects a2  
		|INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
		|WHERE a2.type <> N'S' and a2.type <> N'IT' and type_desc = 'USER_TABLE'
		|";
КонецФункции

Функция РазмерОднойТаблицы(ИмяТаблицы) Экспорт
	Возврат "SELECT 
		|	'" + ИмяТаблицы + "' as [ИмяТаблицыSQL],
		|	a1.rows as [КоличествоСтрок],
		|	(a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved,
		|	a1.data * 8 AS [РазмерДанных],
		|	(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS [РазмерИндекса]
		|FROM
		|	(SELECT 
		|		ps.object_id,
		|		SUM (
		|			CASE
		|				WHEN (ps.index_id < 2) THEN row_count
		|				ELSE 0
		|			END
		|			) AS [rows],
		|		SUM (ps.reserved_page_count) AS reserved,
		|		SUM (
		|			CASE
		|				WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
		|				ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
		|			END
		|			) AS data,
		|		SUM (ps.used_page_count) AS used
		|	FROM sys.dm_db_partition_stats ps
		|	WHERE ps.object_id = object_id('" + ИмяТаблицы + "')
		|	GROUP BY ps.object_id) AS a1
		|LEFT OUTER JOIN 
		|	(SELECT 
		|		it.parent_id,
		|		SUM(ps.reserved_page_count) AS reserved,
		|		SUM(ps.used_page_count) AS used
		|	 FROM sys.dm_db_partition_stats ps
		|	 INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
		|	 WHERE it.internal_type IN (202,204) and it.parent_id = object_id('" + ИмяТаблицы + "')
		|	 GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
		|ORDER BY reserved desc
		|";
КонецФункции

// Определяем фрагментацию перых 100 таблиц
Функция ФрагментацияТаблиц() Экспорт
	
	Возврат " SELECT TOP 100
		 |	 object_name(ps.OBJECT_ID) AS [ИмяТаблицыSQL],
		 |	 Index_Description = CASE
		 |					   WHEN ps.index_id = 1 THEN 'Кластерный индекс'
		 |					   WHEN ps.index_id <> 1 THEN 'Не кластерный индекс'
		 |						 END,
		 |	  b.name AS [ИмяИндекса],
		 |	 ROUND(ps.avg_fragmentation_in_percent,2,1) AS [ПроцентФрагментации],
		 |   SUM(page_count*8) AS [РазмерДанных],
		 |	  ps.page_count
		 |FROM sys.dm_db_index_physical_stats (DB_ID(),NULL,NULL,NULL,NULL) AS ps
		 |INNER JOIN sys.indexes AS b ON ps.object_id = b.object_id AND ps.index_id = b.index_id AND b.index_id <> 0 
		 |INNER JOIN sys.objects AS O ON O.object_id=b.object_id AND O.type='U' AND O.is_ms_shipped=0 
		 |INNER JOIN sys.schemas AS S ON S.schema_Id=O.schema_id
		 |WHERE ps.database_id = DB_ID() 
		 |GROUP BY db_name(ps.database_id),S.name,object_name(ps.OBJECT_ID),CASE WHEN ps.index_id = 1 THEN 'Кластерный индекс' WHEN ps.index_id <> 1 THEN 'Не кластерный индекс' END,b.name,ROUND(ps.avg_fragmentation_in_percent,0,1),ps.avg_fragmentation_in_percent,ps.page_count
		 |HAVING SUM(page_count*8) > 20000
		 |ORDER BY ps.avg_fragmentation_in_percent DESC";
КонецФункции

Функция ФрагментацияОднойТаблицы(ИмяТаблицы) Экспорт
	Возврат " SELECT 
		 |	 object_name(ps.OBJECT_ID) AS [ИмяТаблицыSQL],
		 |	 Index_Description = CASE
		 |					   WHEN ps.index_id = 1 THEN 'Кластерный индекс'
		 |					   WHEN ps.index_id <> 1 THEN 'Не кластерный индекс'
		 |						 END,
		 |	  b.name AS [ИмяИндекса],
		 |	 ROUND(ps.avg_fragmentation_in_percent,2,1) AS [ПроцентФрагментации],
		 |   SUM(page_count*8) AS [РазмерДанных],
		 |	  ps.page_count
		 |FROM sys.dm_db_index_physical_stats (DB_ID(),object_id('" + ИмяТаблицы + "'),NULL,NULL,NULL) AS ps
		 |INNER JOIN sys.indexes AS b ON ps.object_id = b.object_id AND ps.index_id = b.index_id AND b.index_id <> 0 
		 |INNER JOIN sys.objects AS O ON O.object_id=b.object_id AND O.type='U' AND O.is_ms_shipped=0 
		 |INNER JOIN sys.schemas AS S ON S.schema_Id=O.schema_id
		 |WHERE ps.database_id = DB_ID()
		 |GROUP BY db_name(ps.database_id),S.name,object_name(ps.OBJECT_ID),CASE WHEN ps.index_id = 1 THEN 'Кластерный индекс' WHEN ps.index_id <> 1 THEN 'Не кластерный индекс' END,b.name,ROUND(ps.avg_fragmentation_in_percent,0,1),ps.avg_fragmentation_in_percent,ps.page_count
		 |ORDER BY ps.avg_fragmentation_in_percent DESC";
КонецФункции

// Получаем информацию о 30 последних архивах
Функция ИнформацияОБекапах() Экспорт
	
	Возврат "SELECT TOP (30) 
		|bs.server_name as [Сервер], 
		|bs.database_name AS [БазаДанных], 
		|recovery_model as [МодельВосстановления],
		|type as [ТипБекапа],
		|CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [РазмерМБ],
		|DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [ДлительностьБекапаСекунд],
		|backup_start_date as [ДатаНачала],
		|bs.backup_finish_date as [ДатаЗавершения],
		|F.physical_device_name as [ИмяФайла]
        |
		|FROM msdb.dbo.backupset AS bs WITH (NOLOCK) 
		|	JOIN msdb.dbo.backupmediafamily F ON bs.media_set_id = F.media_set_id
		|WHERE bs.backup_size > 0
		|	AND database_name = DB_NAME(DB_ID())
		|ORDER BY bs.backup_finish_date DESC OPTION (RECOMPILE);";

КонецФункции

Функция ИзмененияКонфигурации() Экспорт
	
	//Возврат "SELECT TOP 1 [Modified]
	Возврат "SELECT TOP 1 convert(datetime,[Modified], 120) as Modified
		  |   
		  |FROM [dbo].[Config] with (nolock)
		  |
		  | WHERE FileName = 'versions'
		  |  ORDER BY Modified Desc";

КонецФункции
	  
Функция ПараметрыСервера(Номер) Экспорт
	
	Если Номер = 1 Тогда
		Возврат
			"select 
			|cpu_count,
			|hyperthread_ratio,
			|scheduler_count,
			|max_workers_count,
			//|physical_memory_in_bytes/1048576,
			|physical_memory_KB/1024,
			|virtual_machine_type_desc
			|from sys.dm_os_sys_info";
	ИначеЕсли Номер = 2 Тогда
		Возврат
			"select 
			|cpu_count,
			|hyperthread_ratio,
			|scheduler_count,
			|max_workers_count,
			//|physical_memory_in_bytes/1048576,
			|physical_memory_KB/1024
			|-1
			|from sys.dm_os_sys_info"	
	ИначеЕсли Номер = 3 Тогда
		Возврат
			"select 
			|cpu_count,
			|hyperthread_ratio,
			|scheduler_count,
			|max_workers_count,
			|physical_memory_kb/1024,
			|-1
			|from sys.dm_os_sys_info"	
КонецЕсли;
	
КонецФункции

Функция АптаймСервера(Номер) Экспорт
	
	Если Номер = 1 Тогда
		Возврат
		   "SELECT 
			|	 sqlserver_start_time 
			|	,DATEDIFF(hour, sqlserver_start_time , CURRENT_TIMESTAMP) AS diff_hh
			|	,DATEDIFF(day, sqlserver_start_time , CURRENT_TIMESTAMP)  AS diff_dd
			|FROM sys.dm_os_sys_info;";
	ИначеЕсли Номер = 2 Тогда
		Возврат
		    "SELECT 
			|	 create_date AS ServiceStartTime
			|	,DATEDIFF(hour, create_date, CURRENT_TIMESTAMP) AS diff_hh
			|	,DATEDIFF(day, create_date, CURRENT_TIMESTAMP) AS diff_dd
			|FROM SYS.databases WHERE database_id = 2;";
	КонецЕсли;
	
КонецФункции

Функция ИнформацияОСервере(Номер) Экспорт
	
	Если Номер = 1 Тогда
		
		Возврат "SELECT @@SERVERNAME AS [ServerName], @@VERSION AS [ServerVersion];";
		
	ИначеЕсли Номер = 2 Тогда
		
		Возврат "SELECT @@SERVERNAME AS [ServerName], createdate   
			|FROM sys.syslogins 
			|WHERE [sid] = 0x010100000000000512000000;";
		
	ИначеЕсли Номер = 3 Тогда
		
		Возврат "SELECT SERVERPROPERTY('MachineName') AS [MachineName], SERVERPROPERTY('ServerName') AS [ServerName],  
			|SERVERPROPERTY('InstanceName') AS [Instance], SERVERPROPERTY('IsClustered') AS [IsClustered], 
			|SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
			|SERVERPROPERTY('Edition') AS [Edition], SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
			|SERVERPROPERTY('ProductVersion') AS [ProductVersion], SERVERPROPERTY('ProcessID') AS [ProcessID],
			|SERVERPROPERTY('Collation') AS [Collation], SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
			|SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
			|SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled], SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus];";
		
	ИначеЕсли Номер = 4 Тогда
		
		Возврат "SELECT windows_release, windows_service_pack_level, 
			|	   windows_sku, os_language_version
			|FROM sys.dm_os_windows_info WITH (NOLOCK) OPTION (RECOMPILE);";
		
	ИначеЕсли Номер = 5 Тогда
		
		Возврат "EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE',
		
			|'HARDWARE\DESCRIPTION\System\CentralProcessor\0','ProcessorNameString';";
	ИначеЕсли Номер = 6 Тогда
		
		Возврат "EXEC xp_readerrorlog 0,1,""Manufacturer"";";
		
	ИначеЕсли Номер = 7 Тогда
		
		Возврат "SELECT
			|DatabaseName = DB_NAME(database_id)
			|,count(*) as count
			|FROM sys.dm_db_missing_index_details
			|WHERE database_id = DB_ID()
			|GROUP BY DB_NAME(database_id)
			|ORDER BY 2 DESC;";
		
	ИначеЕсли Номер = 8 Тогда
		
		Возврат "--Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e (Balanced) *
				|--Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c (High performance)
				|--Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a (Power saver)
				|DECLARE @value VARCHAR(64)
 				|DECLARE @key VARCHAR(512)
				|SET @key = 'SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes';
 				|EXEC master..xp_regread 
				|@rootkey = 'HKEY_LOCAL_MACHINE',
				|@key = @key  ,
				|@value_name = 'ActivePowerScheme',
				|@value = @value OUTPUT;

				|SELECT @value;";
		
	ИначеЕсли Номер = 9 Тогда // DFSS EnableFairShare 			
		
		Возврат "EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE',
			|'SYSTEM\CurrentControlSet\Services\TSFairShare\Disk','EnableFairShare';";
		
	ИначеЕсли Номер = 10 Тогда // EnableCpuQuota 			
		
		Возврат "EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE',
			|'SYSTEM\CurrentControlSet\Control\Session Manager\Quota System','EnableCpuQuota';";
		
	ИначеЕсли Номер = 11 Тогда // использование SharedMemory 			
		
		Возврат "select program_name,net_transport
			|from sys.dm_exec_sessions as t1
			|left join sys.dm_exec_connections AS t2 ON t1.session_id=t2.session_id
			|where not t1.program_name is null;";
		
	ИначеЕсли Номер = 12 Тогда // Контроль учетных записей и применение политики UAC 			
		
		Возврат "EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE',
			|'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System','EnableLUA';";
		
	КонецЕсли;
	
КонецФункции

Функция ИнформацияОБазеДанных() Экспорт
	
	Возврат "SELECT 
			|name,
			|create_date,
			|compatibility_level,
			|collation_name,
			|is_read_only,
			|snapshot_isolation_state,
			|is_read_committed_snapshot_on,
			|recovery_model_desc,
			|is_auto_create_stats_on,
			|is_auto_update_stats_on
			|FROM sys.databases
			|WHERE database_id = DB_ID()";
КонецФункции
		
Функция ИнформацияОПараметрахСервера() Экспорт
	
	Возврат "SELECT name [Параметр], value [ЗНачение], value_in_use [ИспользуемоеЗначение], [description] as [Описание]
			|FROM sys.configurations WITH (NOLOCK)
			|ORDER BY name OPTION (RECOMPILE)";
	
КонецФункции
		
Функция ЗапущенныеСлужбы() Экспорт
	
	Возврат "SELECT servicename [Сервис], startup_type_desc [СпособЗапуска], status_desc [Статус], 
			|last_startup_time [ПоследнийЗапуск], service_account [Аккаунт], is_clustered [Кластерный], cluster_nodename [ИмяКластера]
			|FROM sys.dm_server_services WITH (NOLOCK) OPTION (RECOMPILE);";
	
КонецФункции		
		
Функция ФлагиТрассировки() Экспорт
	
	Возврат "DBCC TRACESTATUS (-1)";
	
КонецФункции		

Функция Дампы() Экспорт
	
	Возврат "SELECT [filename] [ФайлДампа], creation_time [Дата], size_in_bytes/1024 as [РазмерКБ]
			|FROM sys.dm_server_memory_dumps WITH (NOLOCK) OPTION (RECOMPILE);";
	
КонецФункции		

Функция ИспользованиеИндексов() Экспорт
	
	Возврат "SELECT TOP 50 OBJECT_NAME(s.[object_id]) AS [Таблица], i.name AS [Индекс], i.index_id,
			|	s.user_updates AS [Writes], user_seeks + user_scans + user_lookups AS [Reads], 
			|	i.type_desc AS [ТипИндекса], i.fill_factor AS [FillFactor]
			|FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
			|INNER JOIN sys.indexes AS i WITH (NOLOCK)
			|ON s.[object_id] = i.[object_id]
			|WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
			|AND i.index_id = s.index_id
			|AND s.database_id = DB_ID()
			|ORDER BY s.user_updates DESC OPTION (RECOMPILE);";
	
КонецФункции	
		
Функция Базы() Экспорт
	
	Возврат "SELECT DB_NAME([database_id])AS [БазаДанных], 
			|[file_id], 
			|name, 
			|physical_name [ИмяФайла], 
			|type_desc [Тип], 
			|state_desc, 
			|	   CONVERT( bigint, size/128.0) AS [РазмерМБ]
			|FROM sys.master_files WITH (NOLOCK)
			|WHERE [database_id] > 4 
			|AND [database_id] <> 32767
			|OR [database_id] = 2
			|ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);";
	
КонецФункции	

Функция ДоступноеМесто() Экспорт
	
	Возврат "SELECT DB_NAME(f.database_id) AS [БазаДанных], 
			|f.file_id, 
			|vs.volume_mount_point [Диск], 
			|vs.total_bytes [РазмерМБ], 
			|vs.available_bytes [ДоступноМБ], 
			|CAST(CAST(vs.available_bytes AS FLOAT)/ CAST(vs.total_bytes AS FLOAT) AS DECIMAL(18,3)) * 100 AS [СвободноПроцент]
			|FROM sys.master_files AS f
			|CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
			|WHERE f.database_id = DB_ID() 
			|ORDER BY f.database_id OPTION (RECOMPILE);";
	
КонецФункции

Функция ИнтенсивностьИспользования() Экспорт
	
	Возврат "select db_name(mf.database_id) as  [БазаДанных], 
			|mf.physical_name [ИмяФайла],
			|num_of_reads, 
			|num_of_bytes_read, 
			|io_stall_read_ms, 
			|num_of_writes,
			|num_of_bytes_written,  
			|io_stall_write_ms, 
			|io_stall,
			|size_on_disk_bytes
			|from sys.dm_io_virtual_file_stats(null,null) as divfs
			|join sys.master_files as mf
			|on mf.database_id = divfs.database_id
			|and mf.file_id = divfs.file_id
			|order by 9 desc";
	
КонецФункции

Функция ИспользованиеПроцессора() Экспорт
	
	Возврат "WITH DB_CPU_Stats
			|AS
			|(SELECT DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms]
			| FROM sys.dm_exec_query_stats AS qs
			| CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
			|			  FROM sys.dm_exec_plan_attributes(qs.plan_handle)
			|			  WHERE attribute = N'dbid') AS F_DB
			| GROUP BY DatabaseID)
			|SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
			|	   DatabaseName [БазаДанных], [CPU_Time_Ms], 
			|	   CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Процент]
			|FROM DB_CPU_Stats
			|WHERE DatabaseID > 4 
			|AND DatabaseID <> 32767 
			|ORDER BY row_num OPTION (RECOMPILE);";
	
КонецФункции

Функция ИспользованиеКеша() Экспорт
	
	Возврат "SELECT DB_NAME(database_id) AS [БазаДанных],
			|COUNT(*) * 8/1024.0 AS [CashedSizeMB]
			|FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
			|WHERE database_id > 4 
			|AND database_id <> 32767 
			|GROUP BY DB_NAME(database_id)
			|ORDER BY [CashedSizeMB] DESC OPTION (RECOMPILE);";
	
КонецФункции

Функция Ожидания(Номер = 1) Экспорт
	
	Если Номер = 1 Тогда
		
		Возврат "WITH Waits AS
			|(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
			|100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
			|ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
			|FROM sys.dm_os_wait_stats WITH (NOLOCK)
			|WHERE wait_type NOT IN (
			|N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',
			|N'SLEEP_TASK',N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', 
			|N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
			|N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
			|N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
			|N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
			|N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
			|N'DIRTY_PAGE_POLL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'SP_SERVER_DIAGNOSTICS_SLEEP',
			|N'QDS_SHUTDOWN_QUEUE',
			|N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'))
			|SELECT W1.wait_type [ТипОжидания], 
			|CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS [Секунд],
			|CAST(W1.pct AS DECIMAL(12, 2)) AS [Процент],
			|CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
			|FROM Waits AS W1
			|INNER JOIN Waits AS W2
			|ON W2.rn <= W1.rn
			|GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
			|HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE);";
		
	Иначе
		
		Возврат " SELECT W1.wait_type [ТипОжидания], 
		   |CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS [Секунд],
		   |CAST(W1.pct AS DECIMAL(12, 2)) AS [Процент],
		   |CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
		   |FROM (SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
		   |100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
		   |ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
		   |FROM sys.dm_os_wait_stats WITH (NOLOCK)
		   |WHERE wait_type NOT IN (
		   |N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',
		   |N'SLEEP_TASK',N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', 
		   |N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
		   |N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
		   |N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
		   |N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
		   |N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		   |N'DIRTY_PAGE_POLL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		   |N'QDS_SHUTDOWN_QUEUE',
		   |N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP')) AS W1
		   |INNER JOIN (SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
		   |100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
		   |ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
		   |FROM sys.dm_os_wait_stats WITH (NOLOCK)
		   |WHERE wait_type NOT IN (
		   |N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',
		   |N'SLEEP_TASK',N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', 
		   |N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
		   |N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
		   |N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
		   |N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
		   |N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		   |N'DIRTY_PAGE_POLL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		   |N'QDS_SHUTDOWN_QUEUE',
		   |N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP')) AS W2
		   |ON W2.rn <= W1.rn
		   |GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
		   |HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE);";
	
	КонецЕсли; 
	
КонецФункции

Функция РазмещениеВБуфферномПуле(Номер=1) Экспорт
	
	Если Номер = 1 Тогда
		
		Возврат "SELECT TOP 50 OBJECT_NAME(p.[object_id]) AS [Таблица], 
			|p.index_id, COUNT(*)/128 AS [РазмерБуфераМБ],  COUNT(*) AS [BufferCount], 
			|p.data_compression_desc AS [Сжатие]
			|FROM sys.allocation_units AS a WITH (NOLOCK)
			|INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
			|ON a.allocation_unit_id = b.allocation_unit_id
			|INNER JOIN sys.partitions AS p WITH (NOLOCK)
			|ON a.container_id = p.hobt_id
			|WHERE b.database_id = CONVERT(int,DB_ID())
			|AND p.[object_id] > 100
			|GROUP BY p.[object_id], p.index_id, p.data_compression_desc
			|ORDER BY [BufferCount] DESC OPTION (RECOMPILE);";
		
	ИначеЕсли Номер = 2 Тогда
		
		Возврат "SELECT TOP 50 OBJECT_NAME(p.[object_id]) AS [Таблица], 
			|p.index_id, COUNT(*)/128 AS [РазмерБуфераМБ],  COUNT(*) AS [BufferCount], 
			|'none' AS [Сжатие]
			|FROM sys.allocation_units AS a WITH (NOLOCK)
			|INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
			|ON a.allocation_unit_id = b.allocation_unit_id
			|INNER JOIN sys.partitions AS p WITH (NOLOCK)
			|ON a.container_id = p.hobt_id
			|WHERE b.database_id = CONVERT(int,DB_ID())
			|AND p.[object_id] > 100
			|GROUP BY p.[object_id], p.index_id
			|ORDER BY [BufferCount] DESC OPTION (RECOMPILE);";
		
	КонецЕсли;	
	
КонецФункции

Функция БольшиеТаблицы(Номер = 1) Экспорт
	
	Если Номер = 1 Тогда
		
		Возврат "SELECT OBJECT_NAME(object_id) AS [Таблица], 
			|SUM(Rows) AS [КоличествоСтрок], data_compression_desc AS [Сжатие]
			|FROM sys.partitions WITH (NOLOCK)
			|WHERE index_id < 2 
			|AND OBJECT_NAME(object_id) NOT LIKE N'sys%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'queue_%' 
			|AND OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%' 
			|AND OBJECT_NAME(object_id) NOT LIKE N'fulltext%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'ifts_comp_fragment%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'filetable_updates%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'xml_index_nodes%'
			|and Rows > 10000000
			|GROUP BY object_id, data_compression_desc
			|ORDER BY SUM(Rows) DESC OPTION (RECOMPILE);";
		
	ИначеЕсли Номер = 2 Тогда
		
		Возврат "SELECT OBJECT_NAME(object_id) AS [Таблица], 
			|SUM(Rows) AS [КоличествоСтрок], 'none' AS [Сжатие]
			|FROM sys.partitions WITH (NOLOCK)
			|WHERE index_id < 2 
			|AND OBJECT_NAME(object_id) NOT LIKE N'sys%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'queue_%' 
			|AND OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%' 
			|AND OBJECT_NAME(object_id) NOT LIKE N'fulltext%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'ifts_comp_fragment%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'filetable_updates%'
			|AND OBJECT_NAME(object_id) NOT LIKE N'xml_index_nodes%'
			|and Rows > 10000000
			|GROUP BY object_id
			|ORDER BY SUM(Rows) DESC OPTION (RECOMPILE);";
		
	КонецЕсли;		
		
	
КонецФункции

Функция Ноды() Экспорт
	
	Возврат "	SELECT node_id, node_state_desc, memory_node_id, online_scheduler_count, 
			|	   active_worker_count, avg_load_balance 
			|	FROM sys.dm_os_nodes WITH (NOLOCK) 
			|	WHERE node_state_desc <> N'ONLINE DAC' OPTION (RECOMPILE);
			|";
	
КонецФункции

Функция ЗадачиАгента() Экспорт
	
	Возврат "SELECT 
			|	[sJOB].[name] AS [ИмяЗадачи]
			|	, [sCAT].[name] AS [Категория]
			|	, [sJOB].[description] AS [Описание]
			|	, CASE [sJOB].[enabled]
			|		WHEN 1 THEN 'Yes'
			|		WHEN 0 THEN 'No'
			|	  END AS [Включена]
			|	, [sJOB].[date_created] AS [ДатаСоздания]
			|	, [sJOB].[date_modified] AS [ДатаМодификации]
			|	, CASE 
			|		WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
			|		ELSE CAST(
			|				CAST([sJOBH].[run_date] AS CHAR(8))
			|				+ ' ' 
			|				+ STUFF(
			|					STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
			|						, 3, 0, ':')
			|					, 6, 0, ':')
			|				AS DATETIME)
			|	  END AS [ДатаЗапуска]
			|, CASE [sJOBH].[run_status]
			|		WHEN 0 THEN 'Failed'
			|		WHEN 1 THEN 'Succeeded'
			|		WHEN 2 THEN 'Retry'
			|		WHEN 3 THEN 'Canceled'
			|		WHEN 4 THEN 'Running' 
			|	  END AS [СтатусЗапуска]
			|	, STUFF(
			|			STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
			|				, 3, 0, ':')
			|			, 6, 0, ':') 
			|		AS [ДлительностьЗапуска]
			|	, [sJOBH].[message] AS [ОписаниеЗапуска]
			|	, CASE [sJOBSCH].[NextRunDate]
			|		WHEN 0 THEN NULL
			|		ELSE CAST(
			|				CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
			|				+ ' ' 
			|				+ STUFF(
			|					STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
			|						, 3, 0, ':')
			|					, 6, 0, ':')
			|				AS DATETIME)
			|	  END AS [СледующийЗапуск]
			|	, (SELECT
			|		   Count(step_name)
			|		FROM
			|			[msdb].[dbo].[sysjobsteps] WHERE job_id = [sJOB].job_id) AS [КоличествоШагов]
			|			
			|FROM
			|	[msdb].[dbo].[sysjobs] AS [sJOB]
			|	LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
			|		ON [sJOB].[category_id] = [sCAT].[category_id]
			|	LEFT JOIN (
			|				SELECT
			|					[job_id]
			|					, MIN([next_run_date]) AS [NextRunDate]
			|					, MIN([next_run_time]) AS [NextRunTime]
			|				FROM [msdb].[dbo].[sysjobschedules]
			|				GROUP BY [job_id]
			|			) AS [sJOBSCH]
			|		ON [sJOB].[job_id] = [sJOBSCH].[job_id]
			|	LEFT JOIN (
			|				SELECT 
			|					[job_id]
			|					, [run_date]
			|					, [run_time]
			|					, [run_status]
			|					, [run_duration]
			|					, [message]
			|					, ROW_NUMBER() OVER (
			|											PARTITION BY [job_id] 
			|											ORDER BY [run_date] DESC, [run_time] DESC
			|					  ) AS RowNumber
			|				FROM [msdb].[dbo].[sysjobhistory]
			|				WHERE [step_id] = 0
			|			) AS [sJOBH]
			|		ON [sJOB].[job_id] = [sJOBH].[job_id]
			|		AND [sJOBH].[RowNumber] = 1
			|ORDER BY [ИмяЗадачи]";
	
КонецФункции

Функция ИнформацияОБазах() Экспорт
	
	Возврат "SELECT database_id,
			|CONVERT(VARCHAR(25), DB.name) AS dbName,
			|CONVERT(VARCHAR(10), DATABASEPROPERTYEX(name, 'status')) AS [status],
			|(SELECT COUNT(1) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS dataFiles,
			|(SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [dataMB],
			|(SELECT COUNT(1) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS logFiles,
			|(SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [logMB],
			|user_access_desc AS [userAccess],
			|recovery_model_desc AS [recoveryModel],
			|compatibility_level,
			|create_date AS [creation_date],
			|ISNULL((SELECT TOP 1
			|CASE TYPE WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction log' END + ' – ' +
			|LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(),Backup_finish_date))) + ' days ago', 'NEVER')) + ' – ' +
			|CONVERT(VARCHAR(20), backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) + ' – ' +
			|CONVERT(VARCHAR(20), backup_finish_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_finish_date, 108) +
			|' (' + CAST(DATEDIFF(second, BK.backup_start_date,
			|BK.backup_finish_date) AS VARCHAR(4)) + ' '
			|+ 'seconds)'
			|FROM msdb..backupset BK WHERE BK.database_name = DB.name ORDER BY backup_set_id DESC),'-') AS [last_backup],
			|is_fulltext_enabled,
			|is_auto_close_on,
			|page_verify_option_desc ,
			|is_read_only,
			|is_auto_shrink_on,
			|is_auto_create_stats_on,
			|is_auto_update_stats_on,
			|is_in_standby,
			|is_cleanly_shutdown,
			|snapshot_isolation_state,
			|is_read_committed_snapshot_on
			|FROM sys.databases DB";
	
КонецФункции

Функция ПроблемыСПамятью() Экспорт
	
	Возврат "WITH RingBufferXML
	| AS(SELECT CAST(Record AS XML) AS RBR FROM sys .dm_os_ring_buffers
	| WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
	|) SELECT DISTINCT 'ЗафиксированыПроблемы' =
	|   CASE
	|            WHEN XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint')  = 0 AND
	|                XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]','tinyint')   = 2 
	|          THEN 'Недостаточно физической памяти для системы'
	|         WHEN XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint')  = 0 AND 
	|             XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]','tinyint')   = 4 
	|                  THEN 'Недостаточно виртуальной памяти для системы' 
	|                  WHEN XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]', 'tinyint') = 2 AND 
	|                      XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]','tinyint')   = 0 
	|                THEN'Недостаточно физической памяти для запросов'
	|               WHEN XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]', 'tinyint') = 4 AND 
	|                   XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]', 'tinyint')  = 4
	|             THEN 'Недостаточно виртуальной памяти для запросов и системы'
	|            WHEN XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint')  = 2 AND 
	|                XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]','tinyint')   = 4 
	|          THEN 'Недостаточно виртуальной памяти для системы и физической для запросов'
	|         WHEN XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]', 'tinyint') = 2 AND 
	|             XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]', 'tinyint')  = 2 
	|       THEN 'Недостаточно физической памяти для системы и запросов'
	|END
	|FROM        RingBufferXML
	|CROSS APPLY RingBufferXML.RBR.nodes ('Record') Record (XMLRecord)
	|WHERE       XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint') IN (0,2,4) AND
	|            XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]' ,'tinyint') IN (0,2,4) AND
	|            XMLRecord.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint') +
	|            XMLRecord.value('(ResourceMonitor/IndicatorsSystem)[1]' ,'tinyint') > 0";
	
КонецФункции

Функция ЗагруженностьПроцессора(Номер) Экспорт
	
	Если Номер = 1 Тогда
		
		Возврат "DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) 
				|						  FROM sys.dm_os_sys_info WITH (NOLOCK)); 

				|SELECT TOP(256) 
				|	SQLProcessUtilization AS [ПроцессСУБД], 
				|	SystemIdle AS [Бездействие], 
				|	100 - SystemIdle - SQLProcessUtilization AS [ОстальныеПроцессы], 
				|	DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Дата] 
				|FROM ( 
				|   SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
				|   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
				|   AS [SystemIdle], 
				|   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
				|   'int') 
				|   AS [SQLProcessUtilization], [timestamp] 
				|   FROM ( 
				|   SELECT [timestamp], CONVERT(xml, record) AS [record] 
				|   FROM sys.dm_os_ring_buffers WITH (NOLOCK)
				|   WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
				|   AND record LIKE N'%<SystemHealth>%') AS x 
				|   ) AS y 
				|ORDER BY record_id DESC OPTION (RECOMPILE);";
		
	ИначеЕсли Номер = 2 Тогда 	
		
		Возврат "DECLARE @ts_now bigint;
				|SET @ts_now = (SELECT cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info);
				|SELECT TOP(256) 
				|	SQLProcessUtilization AS [ПроцессСУБД], 
				|	SystemIdle AS [Бездействие], 
				|	100 - SystemIdle - SQLProcessUtilization AS [ОстальныеПроцессы], 
				|	DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Дата] 
				|FROM ( 
				|   SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
				|   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
				|   AS [SystemIdle], 
				|   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
				|   'int') 
				|   AS [SQLProcessUtilization], [timestamp] 
				|   FROM ( 
				|   SELECT [timestamp], CONVERT(xml, record) AS [record] 
				|   FROM sys.dm_os_ring_buffers WITH (NOLOCK)
				|   WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
				|   AND record LIKE N'%<SystemHealth>%') AS x 
				|   ) AS y 
				|ORDER BY record_id DESC OPTION (RECOMPILE);";
		
	КонецЕсли; 
	
КонецФункции

Функция НулевыеИтоги(мТаблицыХранения, СоздатьМассив) Экспорт
	
	ТекстЗапроса = "";
	
	ШаблонЗапроса = 
			"SELECT 
			|'#ИмяТаблицы#' AS [ИмяТаблицыSQL],
			|'#Метаданные#' AS [Метаданные],
			|'#Назначение#' AS [Назначение],
			|convert(datetime,_Period, 120) as [ПериодИтогов],						--///// |_Period as [ПериодИтогов],
			|#УсловиеКоличествоРесурсов# as [КоличествоСтрок],
			|SUM(CASE WHEN #УсловиеРесурсы# THEN 1 ELSE 0 END) as [КоличествоНулевыхСтрок]
			|FROM #ИмяТаблицы#
			|GROUP BY _Period
			|UNION ALL
			|";
			
	Если СоздатьМассив Тогда
		
		Массив = Новый Массив; 	
		
		ШаблонЗапроса = 
			"SELECT 
			|'#ИмяТаблицы#' AS [ИмяТаблицыSQL],
			|'#Метаданные#' AS [Метаданные],
			|'#Назначение#' AS [Назначение],				
			|convert(datetime,_Period, 120) as [ПериодИтогов],						--///// |_Period as [ПериодИтогов],
			|#УсловиеКоличествоРесурсов# as [КоличествоСтрок],
			|SUM(CASE WHEN #УсловиеРесурсы# THEN 1 ELSE 0 END) as [КоличествоНулевыхСтрок]
			|FROM #ИмяТаблицы#
			|GROUP BY _Period
			|";
		
	КонецЕсли; 

	
	Для каждого Таблица из мТаблицыХранения Цикл
		
		ТекТекстЗапроса = "";
		
		Если Таблица.Назначение = "Итоги" ИЛИ Таблица.Назначение = "ИтогиПоСчетам"  ИЛИ Лев(Таблица.Назначение,22) = "ИтогиПоСчетамССубконто" Тогда 
			
			ТекТекстЗапроса = ШаблонЗапроса;
			ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#ИмяТаблицы#", Таблица.ИмяТаблицыХранения);
			ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#Метаданные#", Таблица.Метаданные);
			ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#Назначение#", Таблица.Назначение);
			
			УсловиеРесуры = "";
			
			ИспользуетсяРазделитель = Ложь;
			
			Для каждого Поле ИЗ Таблица.Поля Цикл
				Если Поле.ИмяПоляХранения = "_Splitter" Тогда
					ИспользуетсяРазделитель = Истина;
					УсловиеРесуры = УсловиеРесуры + Поле.ИмяПоляХранения + " = 0 AND ";
				КонецЕсли;
				Если Найти(Поле.Метаданные, "Ресурс") <> 0  Тогда
					УсловиеРесуры = УсловиеРесуры + Поле.ИмяПоляХранения + " = 0 AND ";
				КонецЕсли;
			КонецЦикла;
			
			УсловиеРесуры = ЛЕВ(УсловиеРесуры, СтрДлина(УсловиеРесуры)-5);
			
			Если СтрДлина(УсловиеРесуры)=0 Тогда
				Продолжить;
			КонецЕсли; 
			
			Если ИспользуетсяРазделитель Тогда
				ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#УсловиеКоличествоРесурсов#", "SUM(CASE WHEN _splitter=0 THEN 1 ELSE 0 END)");
			Иначе
				ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#УсловиеКоличествоРесурсов#", "COUNT(*)");
			КонецЕсли;
			
			ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#УсловиеРесурсы#", УсловиеРесуры);
			
		КонецЕсли;
		
		Если СоздатьМассив И ЗначениеЗаполнено(ТекТекстЗапроса) Тогда
			Массив.Добавить(ТекТекстЗапроса);	
		Иначе
			ТекстЗапроса = ТекстЗапроса + ТекТекстЗапроса;
		КонецЕсли; 
		
	КонецЦикла;
	
	Если СтрДлина(ТекстЗапроса)>0 Тогда
		
		ТекстЗапроса = ЛЕВ(ТекстЗапроса, СтрДлина(ТекстЗапроса)-10) + "ORDER BY 1,2";	
		
	КонецЕсли; 
	
	Возврат ?(СоздатьМассив, Массив, ТекстЗапроса);
	
КонецФункции

Функция ДиапазонДокументов(мТаблицыХранения) Экспорт
	
	ТекстЗапроса = "";
	
	ШаблонЗапроса = 
			"SELECT 
			|'#ИмяТаблицы#' AS [ИмяТаблицыSQL],
			|'#Метаданные#' AS [Метаданные],
			|convert(datetime,MIN(_Date_Time), 120) AS [ПериодС],						----- |MIN(_Date_Time) AS [ПериодС],
			|convert(datetime,MAX(_Date_Time), 120) AS [ПериодПо] 						----- |MAX(_Date_Time) AS [ПериодПо] 
			|FROM #ИмяТаблицы#
			|UNION ALL
			|";

	
	Для каждого Таблица из мТаблицыХранения Цикл
		
		ТекТекстЗапроса = "";
		
		Если Таблица.Назначение = "Основная" И Лев(Таблица.ИмяТаблицы,8) = "Документ" Тогда 
			
			ТекТекстЗапроса = ШаблонЗапроса;
			ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#ИмяТаблицы#", Таблица.ИмяТаблицыХранения);
			ТекТекстЗапроса = СтрЗаменить(ТекТекстЗапроса, "#Метаданные#", Таблица.Метаданные);
			
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса + ТекТекстЗапроса;
		
	КонецЦикла;
	
	ТекстЗапроса = ЛЕВ(ТекстЗапроса, СтрДлина(ТекстЗапроса)-10) + "ORDER BY 1,2";
		
	Возврат ТекстЗапроса;
	
КонецФункции

Функция РекоменуемыеИндексы(Номер) Экспорт
	
	Если Номер = 1 Тогда
		
		//2008
		
		ТекстЗапроса = 
		"SELECT 
		|DB_NAME(mid.database_id) as [ИмяБазы],
		|migs.unique_compiles as [ЧислоКомпиляций],
		|migs.user_seeks as [КоличествоОперацийПоиска],
		|migs.user_scans as [КоличествоОперацийПросмотра],
		|CAST(migs.avg_total_user_cost AS int) as [СредняяСтоимость],
		|CAST(migs.avg_user_impact AS int) as [СреднийПроцентВыигрыша],
		|OBJECT_NAME(mid.object_id,mid.database_id) as [ТаблицаИндекса],
		|migs.avg_user_impact*(migs.user_seeks+migs.user_scans) as [СреднееПредполагаемоеВлияние],
		|'CREATE INDEX [IX_' +OBJECT_NAME(mid.object_id,mid.database_id) + '_'
		|+ REPLACE(REPLACE(REPLACE(ISNULL(mid.equality_columns,''),', ','_'),'[',''),']','') +
		|CASE
		|WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN '_'
		|ELSE ''
		|END
		|+ REPLACE(REPLACE(REPLACE(ISNULL(mid.inequality_columns,''),', ','_'),'[',''),']','')
		|+ ']'
		|+ ' ON ' + mid.statement
		|+ ' (' + ISNULL (mid.equality_columns,'')
		|+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE
		|'' END
		|+ ISNULL (mid.inequality_columns, '')
		|+ ')'
		|+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS [РекомендуемыйИндекс]
		|FROM sys.dm_db_missing_index_groups mig
		|JOIN sys.dm_db_missing_index_group_stats migs
		|ON migs.group_handle = mig.index_group_handle
		|JOIN sys.dm_db_missing_index_details mid
		|ON mig.index_handle = mid.index_handle
		|WHERE 
		| migs.avg_user_impact*(migs.user_seeks+migs.user_scans) > 10000
		| AND CAST(migs.avg_total_user_cost AS int) < 10
		| AND mid.database_id = DB_ID()
		|ORDER BY [СреднееПредполагаемоеВлияние] desc";
		
	ИначеЕсли Номер = 2 Тогда
		
		//2005
		ТекстЗапроса = 
		"SELECT 
		|DB_NAME(mid.database_id) as [ИмяБазы],
		|migs.unique_compiles as [ЧислоКомпиляций],
		|migs.user_seeks as [КоличествоОперацийПоиска],
		|migs.user_scans as [КоличествоОперацийПросмотра],
		|CAST(migs.avg_total_user_cost AS int) as [СредняяСтоимость],
		|CAST(migs.avg_user_impact AS int) as [СреднийПроцентВыигрыша],
		|OBJECT_NAME(mid.object_id) as [ТаблицаИндекса],
		|migs.avg_user_impact*(migs.user_seeks+migs.user_scans) as [СреднееПредполагаемоеВлияние],
		|'CREATE INDEX [IX_' + OBJECT_NAME(mid.OBJECT_ID) + '_'
		|+ REPLACE(REPLACE(REPLACE(ISNULL(mid.equality_columns,''),', ','_'),'[',''),']','') +
		|CASE
		|WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN '_'
		|ELSE ''
		|END
		|+ REPLACE(REPLACE(REPLACE(ISNULL(mid.inequality_columns,''),', ','_'),'[',''),']','')
		|+ ']'
		|+ ' ON ' + mid.statement
		|+ ' (' + ISNULL (mid.equality_columns,'')
		|+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE
		|'' END
		|+ ISNULL (mid.inequality_columns, '')
		|+ ')'
		|+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS [РекомендуемыйИндекс]
		|FROM sys.dm_db_missing_index_groups mig
		|JOIN sys.dm_db_missing_index_group_stats migs
		|ON migs.group_handle = mig.index_group_handle
		|JOIN sys.dm_db_missing_index_details mid
		|ON mig.index_handle = mid.index_handle
		|WHERE 
		| migs.avg_user_impact*(migs.user_seeks+migs.user_scans) > 10000
		| AND CAST(migs.avg_total_user_cost AS int) < 10
		| AND mid.database_id = DB_ID()
		|ORDER BY [СреднееПредполагаемоеВлияние] desc";
		
	КонецЕсли;
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция ОшибкиВЛоге(СтрокаПоиска) Экспорт
	
	Возврат "EXEC sp_readerrorlog 0, 1, '" + СтрокаПоиска + "'";
	
КонецФункции
 
Функция ДатаОбновленияСтатистики() Экспорт
	
	Возврат "SELECT object_name(object_id) as [ИмяТаблицы],
			|name AS [ИмяИндекса], 
			|	STATS_DATE(object_id, index_id) AS [ДатаОбновления]
			|FROM sys.indexes ";
	
КонецФункции

Функция ОчиститьСтатистикуОжиданий() Экспорт
	
	Возврат "DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);";
	
КонецФункции

Функция Топ10ЗапросовПоНагрузкеНаПроцессор() Экспорт
	
	ТекстЗапроса = 
	"SELECT top 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
	|((CASE qs.statement_end_offset
	|WHEN -1 THEN DATALENGTH(qt.TEXT)
	|ELSE qs.statement_end_offset
	|END - qs.statement_start_offset)/2)+1) as query_text,
	|qs.execution_count,
	|qs.total_logical_reads, qs.last_logical_reads,
	|qs.total_logical_writes, qs.last_logical_writes,
	|qs.total_worker_time,
	|qs.last_worker_time,
	|qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
	|qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
	|qs.last_execution_time
	|--,qp.query_plan
	|FROM sys.dm_exec_query_stats qs
	|CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	|CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	|ORDER BY qs.total_worker_time DESC -- CPU time;";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция СистемныеСчетчики() Экспорт
	
	ТекстЗапроса = 
	"SELECT 
	|	object_name AS Категория,
	|	counter_name AS ИмяСчетчика, 
	|	instance_name AS ЭкземплярСчетчика, 
	|	cntr_value AS Значение, 
	|	cntr_type AS ТипСчетчика	
	|FROM sys.dm_os_performance_counters
	|WHERE (object_name = 'SQLServer:General Statistics' AND counter_name = 'Logical Connections')
	|	OR
	|	(object_name = 'SQLServer:Databases' AND instance_name = '_Total'
	|		AND counter_name = 'Active Transactions')
	|	OR
	|	(cntr_type = 65792
	|		AND object_name = 'SQLServer:General Statistics'
	|		AND counter_name = 'Processes blocked')";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция ОбщесистемныеОжидания() Экспорт
	
	ТекстЗапроса = 
	"select 
	|	latch_class as 'ТипОжидания',
	|	waiting_requests_count as 'КоличествоСобытий',
	|	(wait_time_ms/1000) as 'НакопленныеОжидания',
	|	(max_wait_time_ms/1000) as 'МаксимальноеОжидание'
	|from
	|	sys.dm_os_latch_stats where max_wait_time_ms > 1000";
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция СбросОбщесистемныхОжиданий() Экспорт
	
	ТекстЗапроса = "DBCC SQLPERF ('sys.dm_os_latch_stats',CLEAR)";
	
	Возврат ТекстЗапроса;
	
КонецФункции




