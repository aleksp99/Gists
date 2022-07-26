#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не GistsПовтИсп.ТокенАвтора() = Неопределено Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Ответа = ВызватьHTTPМетод("/login/device/code?scope=gist&client_id=" + ИдентификаторКлиентаGitHub());
	КодПодтверждения = Ответа.user_code;
	device_code = Ответа.device_code;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗапуститьПриложение("https://github.com/login/device");
	
	ПодключитьОбработчикОжидания("ПолучитьТокен", 5);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция ВызватьHTTPМетод(Адрес)
	
	СоединениеHTTP = Новый HTTPСоединение("github.com",,,,,, Новый ЗащищенноеСоединениеOpenSSL());		
	ЗапросHTTP = Новый HTTPЗапрос(Адрес);
	ЗапросHTTP.Заголовки.Вставить("Accept", "application/json");
	
	ОтветHTTP = СоединениеHTTP.ВызватьHTTPМетод("POST", ЗапросHTTP);
	
	Возврат GistsКлиентСервер.ЗначениеИзСтрокиJSOM(ОтветHTTP.ПолучитьТелоКакСтроку());
	
КонецФункции

&НаКлиенте
Процедура ПолучитьТокен()
	
	Ответа = ВызватьHTTPМетод(СтрШаблон(
	"login/oauth/access_token?client_id=%1&device_code=%2&grant_type=urn:ietf:params:oauth:grant-type:device_code",
		ИдентификаторКлиентаGitHub(), device_code));
	
	Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Ответа, "access_token") Тогда
		СохранитьТокен(Ответа.access_token);
		Закрыть();
	Иначе
		ПодключитьОбработчикОжидания("ПолучитьТокен", 5);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СохранитьТокен(Токен)
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Пользователи.ТекущийПользователь(), Токен, "ТокенGitHub");
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ИдентификаторКлиентаGitHub()
	Возврат "433b10328749643620ad";
КонецФункции

#КонецОбласти