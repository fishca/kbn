Функция СтрокаСоединения(SQLServer,Настройка) Экспорт
	
	SQLServer.CursorLocation=3;   
	SQLServer.ConnectionTimeout = 25;
	SQLServer.CommandTimeout = 1200;
	
	
	Если Настройка.АутентификацияWindows Тогда
		СтрокаСоединения = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=" + Настройка.БазаДанных + ";Data Source=" + Настройка.ИмяСервераSQL;
	Иначе	
		СтрокаСоединения = "Provider=SQLOLEDB.1;Password=" + Настройка.ПарольSQL + ";Persist Security Info=True;User ID=" + Настройка.ЛогинSQL + ";Initial Catalog=" + Настройка.БазаДанных + ";Data Source=" + Настройка.ИмяСервераSQL;
	КонецЕсли; 

	Возврат СтрокаСоединения;
КонецФункции


Функция СоздатьТаблицуХраненияЗначенийСервер(Настройка) Экспорт
	
	
	Флаг =  Истина;
	Попытка
		SQLServer = Новый COMОбъект("ADODB.Connection");
		SQLServer.ConnectionString = СтрокаСоединения(SQLServer,Настройка);
		RecSet= Новый COMОбъект("ADODB.Recordset");
		SQLServer.Open();	
	Исключение
		ВызватьИсключение ОписаниеОшибки();
		Флаг =  Ложь;
	КонецПопытки; 
	
	Если Флаг тогда
		
		
		ТекстЗапроса =" 
		|USE [ИмяБазы]
		|IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StatusData]') AND type in (N'U'))
		|DROP TABLE [dbo].[StatusData]
		|SET ANSI_NULLS ON
		|
		|SET QUOTED_IDENTIFIER ON
		|
		|SET ANSI_PADDING ON
		|
		|CREATE TABLE [dbo].[StatusData](
		|   [id] [int] IDENTITY(1,1) NOT NULL,
		|	[BaseName] [nvarchar] (100) NOT NULL,
		|   [TableZamer] [ntext] NOT NULL
        |) ON [PRIMARY]
		|
		|SET ANSI_PADDING OFF";
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса,"ИмяБазы",Настройка.БазаДанных);
		
		RecSet.Open(ТекстЗапроса,SQLServer,3,1,1);
				
		
		Попытка   		
			SQLServer.Close(); 
		Исключение 		
		КонецПопытки;  
		
	КонецЕсли;
	
	Возврат Флаг;
КонецФункции


Функция ЗаписатьДанныеВБазуМониторинга(Настройка,ТаблицаЗамеров)  Экспорт
	
	Флаг =  Истина;
	БазыМониторинга = Настройка.БазыМониторинга;
	
	
	Попытка
		SQLServer = Новый COMОбъект("ADODB.Connection");
		SQLServer.ConnectionString = СтрокаСоединения(SQLServer,Настройка.НастройкаОфлайнМониторинга);
		RecSet= Новый COMОбъект("ADODB.Recordset");
		SQLServer.Open();	
	Исключение
		ВызватьИсключение ОписаниеОшибки();
		Флаг =  Ложь;
	КонецПопытки; 
	
	Если Флаг тогда
		Попытка  
			Command = Новый COMОбъект("ADODB.Command");
			Command.ActiveConnection = SQLServer;
			Command.CommandType=1;   
			
			
			Для каждого Элемент из БазыМониторинга Цикл
				
				
				текТаблицаЗамеров = ТаблицаЗамеров.СкопироватьКолонки();
				
				ИмяБазы =Элемент.Ключ; 
				
				СтруктураПоиска = Новый Структура("ОфлайнМониторинг,ИмяБазы",ИСТИНА,ИмяБазы);
				
				МассивСтрок = ТаблицаЗамеров.НайтиСтроки(СтруктураПоиска);
				
				Для каждого ЭлементМассива из МассивСтрок Цикл
					СтрокаТекТаблицы = текТаблицаЗамеров.Добавить();
					ЗаполнитьЗначенияСвойств(СтрокаТекТаблицы,ЭлементМассива);
				КонецЦикла;	
				
				
				
				Если текТаблицаЗамеров.Количество() > 0 Тогда
					SQLServer.BeginTrans(); 
					
					ХранилищеТаблицы = Новый ХранилищеЗначения(текТаблицаЗамеров,Новый СжатиеДанных(9));
					
					
					Command.CommandText="INSERT INTO StatusData (BaseName,TableZamer) VALUES (
					| '" + СокрЛП(ИмяБазы) + "', 
					| '" + СокрЛП(ЗначениеВСтрокуВнутр(ХранилищеТаблицы)) + "') ";             
					Command.Execute();
					SQLServer.CommitTrans();
					
				КонецЕсли;
			КонецЦикла;		
 
		Исключение
			Флаг = Ложь;
			SQLServer.RollbackTrans();
			ВызватьИсключение ОписаниеОшибки();
		КонецПопытки;  
		
		Попытка   		
			SQLServer.Close(); 
		Исключение 		
		КонецПопытки;  
		
	КонецЕсли;
	
	Возврат Флаг;
КонецФункции





 