Функция ПодключитьсяКСУБД(Настройка) Экспорт
	
	
	СтрокаСоединения = "Provider=SQLOLEDB.1;Password=" + Настройка.SQLПароль + ";Persist Security Info=True;User ID=" + Настройка.SQLЛогин + ";Initial Catalog=" + Настройка.SQLБаза + ";Data Source=" + Настройка.SQLServer;
	
	Соединение = Неопределено;
	Ошибка = "";
	
	Попытка
	
		Соединение = Новый COMОбъект("ADODB.Connection");
	
		Соединение.ConnectionTimeout = Настройка.ТаймаутПодключения;
	    Соединение.CommandTimeOut = Настройка.ТаймаутПодключения;
	    Соединение.Open(СтрокаСоединения);
	Исключение
		Ошибка = ОписаниеОшибки();
	КонецПопытки;
	
	Возврат Новый Структура("Соединение, Ошибка", Соединение, Ошибка);
	
КонецФункции

Функция ВыполнитьЗапросMSSQL(Соединение, ТекстЗапроса)  Экспорт
	
	objRecordset = Новый COMОбъект("ADODB.Recordset");
	objRecordset.ActiveConnection = Соединение;
	Попытка
		objRecordset.Open(ТекстЗапроса);
	Исключение
		ЗаписьЖурналаРегистрации("SQLSize",,,,"Ошибка выполнения запроса: "+Символы.ПС+СокрЛП(ТекстЗапроса)+Символы.ПС+ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	ТЗ = Новый ТаблицаЗначений;
	Если Число(objRecordset.State) <> 0 Тогда
		
		Для Сч = 0 По objRecordset.Fields.count-1 Цикл
			ИмяКолонки = objRecordset.Fields(Сч).Name;
			Если ИмяКолонки = "" Тогда
				ИмяКолонки = "Колонка" + Сч;
			КонецЕсли;
			ТЗ.Колонки.Добавить(ИмяКолонки);
		КонецЦикла;
		
		Пока objRecordset.EOF = 0 Цикл
			НовСтрока = ТЗ.Добавить();
			Для Сч = 0 По objRecordset.Fields.count-1 Цикл
				ИмяКолонки = objRecordset.Fields(Сч).Name;
				Если ИмяКолонки = "" Тогда
					ИмяКолонки = "Колонка" + Сч;
				КонецЕсли;
				НовСтрока[ИмяКолонки] = objRecordset.Fields(Сч).Value;
			КонецЦикла;
			
			objRecordset.MoveNext();
	  	КонецЦикла;
	  	objRecordset.Close();
	КонецЕсли;
	
	Возврат ТЗ;
	
КонецФункции

Функция ПолучитьСмещениеДат(Соединение) Экспорт
	
	objRecordset = Новый COMОбъект("ADODB.Recordset");
	objRecordset.ActiveConnection = Соединение;
	objRecordset.Open("SELECT offset from _YearOffset");
	Смещение = 0;
	Если Число(objRecordset.State) <> 0 Тогда
		Смещение = objRecordset.Fields(0).Value;
		objRecordset.Close();
	КонецЕсли;
	
	Возврат Смещение;
	
КонецФункции
