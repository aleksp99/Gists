#Область СлужебныйПрограммныйИнтерфейс

Функция ТокенАвтора() Экспорт
	Возврат ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Пользователи.ТекущийПользователь(), "ТокенGitHub")
КонецФункции

Функция ДоступныеРасширения() Экспорт

	Список = Новый СписокЗначений;
	
	Список.Добавить("bsl", "Встроенный язык 1С (.bsl)");
	Список.Добавить("ql", "Язык запросов 1С (.bslq)");
	Список.Добавить("dcs", "Язык выражений СКД 1С (.bslq)");
	Список.Добавить("bat", "Пакетный файл (.bat)");
	Список.Добавить("ps1", "PowerShell (.ps1)");
	Список.Добавить("sql", "SQL (.sql)");
	Список.Добавить("xml", "XML (.xml)");
	Список.Добавить("txt", "Текстовый файл (.txt)");

	Возврат Список;

КонецФункции

#КонецОбласти