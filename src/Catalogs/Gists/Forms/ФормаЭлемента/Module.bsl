#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Элементы.Открытый.ТолькоПросмотр = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Объект.Ссылка.Пустая() Тогда
		
		Объект.Автор = Пользователи.ТекущийПользователь();
		
		Объект.Файлы.Добавить();
		
	КонецЕсли;
	
	Для Каждого Элемент Из Объект.Файлы Цикл
		ДобавитьФайлНаФорму(Элемент);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьДоступностьКомандФайла();
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если Модифицированность Тогда

		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
					   |	&ОписаниеБезТегов КАК Наименование
					   |
					   |ОБЪЕДИНИТЬ ВСЕ
					   |
					   |ВЫБРАТЬ
					   |	""#"" + Теги.Наименование
					   |ИЗ
					   |	Справочник.Теги КАК Теги
					   |ГДЕ
					   |	Теги.Ссылка В(&Ссылка)";
		Запрос.УстановитьПараметр("ОписаниеБезТегов", СокрЛП(ТекущийОбъект.ОписаниеБезТегов));
		Запрос.УстановитьПараметр("Ссылка", ТекущийОбъект.Теги.ВыгрузитьКолонку(0));
		ТекущийОбъект.Описание = СтрСоединить(Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0), " ");
		
		Реквизиты = Метаданные.Справочники.Gists.ТабличныеЧасти.Файлы.Реквизиты;
		Для Каждого Строка Из ТекущийОбъект.Файлы Цикл
			
			Ключ = "Файл" + Формат(Строка.НомерСтроки, "ЧГ=");
			Для Каждого Реквизит Из Реквизиты Цикл
				Строка[Реквизит.Имя] = ЭтаФорма[Ключ + Реквизит.Имя];						
			КонецЦикла;
			
		КонецЦикла;

		Справочники.Gists.ЗаписатьGist(ТекущийОбъект.Идентификатор, ТекущийОбъект);

	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	Реквизиты = Метаданные.Справочники.Gists.ТабличныеЧасти.Файлы.Реквизиты;
	Для Каждого Строка Из Объект.Файлы Цикл
		Ключ = "Файл" + Формат(Строка.НомерСтроки, "ЧГ=");
		Для Каждого Элемент Из Реквизиты Цикл
			ЭтаФорма[Ключ + Элемент.Имя] = Строка[Элемент.Имя];
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	ПроверяемыеРеквизитыКопия = ОбщегоНазначения.СкопироватьРекурсивно(ПроверяемыеРеквизиты);
	ПроверяемыеРеквизиты.Очистить();
	Для Каждого Элемент Из ПроверяемыеРеквизитыКопия Цикл 
		Если Не СтрНачинаетсяС(Элемент, "Файл") Тогда 
			ПроверяемыеРеквизиты.Добавить(Элемент);
		КонецЕсли;
	КонецЦикла;
		
	Для Номер = 1 По Объект.Файлы.Количество() Цикл
		Ключ = "Файл" + Формат(Номер, "ЧГ=");
		ПроверяемыеРеквизиты.Добавить(Ключ + "ИмяБезРасширения");
		ПроверяемыеРеквизиты.Добавить(Ключ + "Расширение");
		ПроверяемыеРеквизиты.Добавить(Ключ + "Тело");	
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементов

&НаКлиенте
Процедура АдресНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЗапуститьПриложение(Объект.Адрес);
	
КонецПроцедуры

#Область Подключаемый_Файл

&НаКлиенте
Процедура Подключаемый_ФайлИмяПриИзменении(Элемент)

	Если СтрЗаканчиваетсяНа(Элемент.Имя, "ИмяБезРасширения") Тогда
		ИмяРеквизита = "ИмяБезРасширения";
	ИначеЕсли СтрЗаканчиваетсяНа(Элемент.Имя, "Расширение") Тогда
		ИмяРеквизита = "Расширение";
	Иначе
		ВызватьИсключение Элемент.Имя;
	КонецЕсли;
	
	ОбновитьИмяФайла(СтрЗаменить(Элемент.Имя, ИмяРеквизита, ""));

КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ФайлАдресНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Не ПустаяСтрока(ЭтаФорма[Элемент.Имя]) Тогда
		ЗапуститьПриложение(ЭтаФорма[Элемент.Имя]);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ДобавитьФайл(Команда)
	
	ДобавитьФайлНаФорму(Объект.Файлы.Добавить().ПолучитьИдентификатор());
	
	УстановитьДоступностьКомандФайла();
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьФайл(Команда)
	
	УдалитьФайлСФормы();
	
	УстановитьДоступностьКомандФайла();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьИзФайла(Команда)
	
	Ключ = ТекущийКлюч();
	Если Ключ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ВыбратьФайлПослеПомещенияФайла", ЭтотОбъект, Ключ);
	ПараметрыЗагрузки = ФайловаяСистемаКлиент.ПараметрыЗагрузкиФайла();
	ПараметрыЗагрузки.Диалог.Расширение = ЭтаФорма[Ключ + "Расширение"];
	ПараметрыЗагрузки.Диалог.Фильтр = ФильтрыФайла();
	ПараметрыЗагрузки.ИдентификаторФормы = УникальныйИдентификатор;
	ФайловаяСистемаКлиент.ЗагрузитьФайл(Оповещение, ПараметрыЗагрузки);

КонецПроцедуры

&НаКлиенте
Процедура СохранитьВФайл(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Ключ = ТекущийКлюч();
	Если Ключ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Поток = Новый ПотокВПамяти;
	ЗаписьТекста = Новый ЗаписьТекста(Поток);
	ЗаписьТекста.Записать(ЭтаФорма[Ключ + "Тело"]);
	ЗаписьТекста.Закрыть();
	ПараметрыСохранения = ФайловаяСистемаКлиент.ПараметрыСохраненияФайла();
	ПараметрыСохранения.Диалог.Расширение = ЭтаФорма[Ключ + "Расширение"];
	ПараметрыСохранения.Диалог.Фильтр = ФильтрыФайла();
	ФайловаяСистемаКлиент.СохранитьФайл(Неопределено, ПоместитьВоВременноеХранилище(
		Поток.ЗакрытьИПолучитьДвоичныеДанные()), ЭтаФорма[Ключ + "Имя"], ПараметрыСохранения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьДоступностьКомандФайла()
	
	Количество = Объект.Файлы.Количество();
	Элементы.УдалитьФайл.Доступность = Количество;
	Элементы.ЗагрузитьИзФайла.Доступность = Количество;
	Элементы.СохранитьВФайл.Доступность = Количество;
	
	Если Количество Тогда
		ЭтаФорма.ТекущийЭлемент = Элементы[СтрШаблон("Файл%1Тело", Формат(Количество, "ЧГ="))];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайлПослеПомещенияФайла(ПомещенныйФайл, Ключ) Экспорт
	
	Если ПомещенныйФайл = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Поток = Новый ПотокВПамяти(ПолучитьБуферДвоичныхДанныхИзДвоичныхДанных(ПолучитьИзВременногоХранилища(
		ПомещенныйФайл.Хранение)));
	ЧтениеТекста = Новый ЧтениеТекста(Поток, КодировкаТекста.UTF8);
	ЭтаФорма[Ключ + "Тело"] = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	Поток.Закрыть();
	
	ЧастиИмениФайла = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(ПомещенныйФайл.Имя);
	ЭтаФорма[Ключ + "ИмяБезРасширения"] = ЧастиИмениФайла.ИмяБезРасширения;
	ЭтаФорма[Ключ + "Расширение"] = Сред(ЧастиИмениФайла.Расширение, 2);
	
	ОбновитьИмяФайла(Ключ); 
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИмяФайла(Ключ)
	
	ЭтаФорма[Ключ + "Имя"] = ЭтаФорма[Ключ + "ИмяБезРасширения"] + ?(ПустаяСтрока(ЭтаФорма[Ключ + "Расширение"]), "",
		".") + ЭтаФорма[Ключ + "Расширение"];

	Элементы["Группа" + Ключ].ЗаголовокСвернутогоОтображения = ЭтаФорма[Ключ + "Имя"];

	Имя = Новый Массив;
	Для Номер = 1 По Объект.Файлы.Количество() Цикл
		Имя.Добавить(ЭтаФорма[СтрШаблон("Файл%1Имя", Номер)]);
	КонецЦикла;
	Объект.Наименование = СтрСоединить(Имя, ", ");
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьФайлНаФорму(Знач Строка)

	Если ТипЗнч(Строка) = Тип("Число") Тогда 
		Строка = Объект.Файлы.НайтиПоИдентификатору(Строка);
	КонецЕсли;
	
	Ключ = "Файл" + Формат(Строка.НомерСтроки, "ЧГ=");
	
	Реквизиты = Метаданные.Справочники.Gists.ТабличныеЧасти.Файлы.Реквизиты;
	ДобавляемыеРеквизиты = Новый Массив;
	Для Каждого Элемент Из Реквизиты Цикл
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы(Ключ + Элемент.Имя, Элемент.Тип,, Элемент.Синоним, Истина));
	КонецЦикла;
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	Для Каждого Элемент Из Реквизиты Цикл 
		ЭтаФорма[Ключ + Элемент.Имя] = Строка[Элемент.Имя];
	КонецЦикла;
	
//	1
	Корень = Элементы.Вставить("Группа" + Ключ, Тип("ГруппаФормы"), Элементы.ГруппаФайлы,
		Элементы.ГруппаФайлыКоманднаяПанель);
	Корень.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	Корень.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
	Корень.Заголовок = " ";
	Корень.Поведение = ПоведениеОбычнойГруппы.Свертываемая;
	Корень.ЗаголовокСвернутогоОтображения = Строка.Имя;
	Корень.ОтображениеУправления = ОтображениеУправленияОбычнойГруппы.Картинка;
	Корень.Отображение = ОтображениеОбычнойГруппы.СильноеВыделение;
//	1.1
	Шапка = Элементы.Добавить(Корень.Имя + "Шапка", Тип("ГруппаФормы"), Корень);
	Шапка.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	Шапка.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Горизонтальная;
	Шапка.ОтображатьЗаголовок = Ложь;
//	1.1.1
	Элемент = Элементы.Добавить(Ключ + "ИмяБезРасширения", Тип("ПолеФормы"), Шапка);
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.ПутьКДанным = Ключ + "ИмяБезРасширения";
	Элемент.Заголовок = "Имя";
	Элемент.УстановитьДействие("ПриИзменении", "Подключаемый_ФайлИмяПриИзменении");
//	1.1.2
	Элемент = Элементы.Добавить(Ключ + "Расширение", Тип("ПолеФормы"), Шапка);
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.ПутьКДанным = Ключ + "Расширение";
	Элемент.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
	Элемент.АвтоМаксимальнаяШирина = Ложь;
	Элемент.МаксимальнаяШирина = 20;
	Элемент.РежимВыбораИзСписка = Истина;
	Для Каждого Расширение Из GistsПовтИсп.ДоступныеРасширения() Цикл
		Элемент.СписокВыбора.Добавить(Расширение.Значение, Расширение.Представление);
	КонецЦикла;
	Элемент.УстановитьДействие("ПриИзменении", "Подключаемый_ФайлИмяПриИзменении");
//	1.1.3
	Элемент = Элементы.Добавить(Ключ + "Адрес", Тип("ПолеФормы"), Шапка);
	Элемент.Вид = ВидПоляФормы.ПолеНадписи;
	Элемент.Гиперссылка = Истина;
	Элемент.ПутьКДанным = Ключ + "Адрес";
	Элемент.УстановитьДействие("Нажатие", "Подключаемый_ФайлАдресНажатие");
//	1.2
	Элемент = Элементы.Добавить(Ключ + "Тело", Тип("ПолеФормы"), Корень);
	Элемент.Вид = ВидПоляФормы.ПолеТекстовогоДокумента;
	Элемент.ПутьКДанным = Ключ + "Тело";
	Элемент.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
//	1.3
	Свойства = Элементы.Добавить(Корень.Имя + "Свойства", Тип("ГруппаФормы"), Корень);
	Свойства.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	Свойства.Заголовок = "Свойства";
	Свойства.ШрифтЗаголовка = Новый Шрифт(,,,,,,, 8);
	Свойства.Поведение = ПоведениеОбычнойГруппы.Свертываемая;
	Свойства.Скрыть();
	Свойства.ОтображениеУправления = ОтображениеУправленияОбычнойГруппы.Картинка;
//	1.3.1
	Элемент = Элементы.Добавить(Ключ + "Тип", Тип("ПолеФормы"), Свойства);
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.ПутьКДанным = Ключ + "Тип";
	Элемент.ТолькоПросмотр = Истина;
	Элемент.АвтоМаксимальнаяШирина = Ложь;
	Элемент.МаксимальнаяШирина = 10;		
//	1.3.2
	Элемент = Элементы.Добавить(Ключ + "Язык", Тип("ПолеФормы"), Свойства);
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.ПутьКДанным = Ключ + "Язык";
	Элемент.ТолькоПросмотр = Истина;
	Элемент.АвтоМаксимальнаяШирина = Ложь;
	Элемент.МаксимальнаяШирина = 10;
//	1.3.3
	Элемент = Элементы.Добавить(Ключ + "Размер", Тип("ПолеФормы"), Свойства);
	Элемент.Вид = ВидПоляФормы.ПолеВвода;
	Элемент.ПутьКДанным = Ключ + "Размер";
	Элемент.ТолькоПросмотр = Истина;
	Элемент.АвтоМаксимальнаяШирина = Ложь;
	Элемент.МаксимальнаяШирина = 5;
//	1.3.4
	Элемент = Элементы.Добавить(Ключ + "Усечение", Тип("ПолеФормы"), Свойства);
	Элемент.Вид = ВидПоляФормы.ПолеФлажка;
	Элемент.ПутьКДанным = Ключ + "Усечение";
	Элемент.ТолькоПросмотр = Истина;
		
КонецПроцедуры

&НаСервере
Процедура УдалитьФайлСФормы()

	Корень = ПолучитьКорень(ЭтаФорма.ТекущийЭлемент);
	Если Корень = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Реквизиты = Метаданные.Справочники.Gists.ТабличныеЧасти.Файлы.Реквизиты;

	Для Каждого Строка Из Объект.Файлы Цикл

		Ключ = "Файл" + Формат(Строка.НомерСтроки, "ЧГ=");
		Для Каждого Реквизит Из Реквизиты Цикл
			Строка[Реквизит.Имя] = ЭтаФорма[Ключ + Реквизит.Имя];
		КонецЦикла;

	КонецЦикла;

	Ключ = "Файл" + Формат(Объект.Файлы.Количество(), "ЧГ=");
	Объект.Файлы.Удалить(Число(Сред(Корень.Имя, 11)) - 1);
	Элементы.Удалить(Элементы["Группа" + Ключ]);
	УдаляемыеРеквизиты = Новый Массив;
	Для Каждого Элемент Из Реквизиты Цикл
		УдаляемыеРеквизиты.Добавить(Ключ + Элемент.Имя);
	КонецЦикла;
	ИзменитьРеквизиты( , УдаляемыеРеквизиты);

	Имя = Новый Массив;
	Для Каждого Строка Из Объект.Файлы Цикл

		Ключ = "Файл" + Формат(Строка.НомерСтроки, "ЧГ=");
		Для Каждого Элемент Из Реквизиты Цикл
			ЭтаФорма[Ключ + Элемент.Имя] = Строка[Элемент.Имя];
		КонецЦикла;
		ЭтаФорма[Ключ + "Имя"] = ЭтаФорма[Ключ + "ИмяБезРасширения"] + ?(ПустаяСтрока(ЭтаФорма[Ключ + "Расширение"]),
			"", ".") + ЭтаФорма[Ключ + "Расширение"];
		Элементы["Группа" + Ключ].ЗаголовокСвернутогоОтображения = ЭтаФорма[Ключ + "Имя"];
		Имя.Добавить(ЭтаФорма[Ключ + "Имя"]);

	КонецЦикла;
	Объект.Наименование = СтрСоединить(Имя, ", ");

КонецПроцедуры

&НаСервере
Функция ПолучитьКорень(Элемент)
	
	Если Элемент = Неопределено Или ТипЗнч(Элемент) = Тип("ФормаКлиентскогоПриложения") Тогда  
		Возврат Неопределено;
		
	ИначеЕсли ТипЗнч(Элемент) = Тип("ГруппаФормы") И СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(СтрЗаменить(
		Элемент.Имя, "ГруппаФайл", "")) Тогда 
		Возврат Элемент;
		
	Иначе 
		Возврат ПолучитьКорень(Элемент.Родитель);
		
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ТекущийКлюч()
	
	Корень = ПолучитьКорень(ЭтаФорма.ТекущийЭлемент);
	Если Корень = Неопределено Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Сред(Корень.Имя, 7);
	
КонецФункции

&НаСервереБезКонтекста
Функция ФильтрыФайла()
	
	Фильтр = Новый Массив;
	
	Для Каждого Элемент Из GistsПовтИсп.ДоступныеРасширения() Цикл
		Фильтр.Добавить(СтрШаблон("%1 (*.%2)|*.%2", Элемент.Представление, Элемент.Значение));
		
	КонецЦикла;
	
	Фильтр.Добавить("Все файлы (*.*)|*.*");
	
	Возврат СтрСоединить(Фильтр, "|");
	
КонецФункции

#КонецОбласти