# postgres-queues

### Задача
Запись в очередь. Приходят клиенты, записываются к операторам.
У оператора 3 кнопки: ВызватьКлиентаИзОчереди (она же, НачатьРаботу), ЗаврешитьОбслуживаниеКлиента, ЗавершитьРаботу.
Для клиентов есть терминалы, в каждом из которых они могут ввести своё имя и записаться к оператору, получив талон. 

Есть таблицы: 
Operators (OperatorID int (счетчик, PK), OperatorPlace varchar, IsWorking bit, 
Queue (QueueID int (счетчик, PK), OperatorID int (FK), RegistrationDate datetime, CustomerFullName varchar, QueueNumber int (каждый день начинается с 1 и увеличивается с каждым новым записавшимся для данного OperatorID), StartServiceDate datetime, EndServiceDate datetime.
Запись в очереди с вызванным клиентом – запись со StartServiceDate не NULL на сегодня.
Запись в очереди с обслуженным клиентом – запись с  EndServiceDate не NULL на сегодня.

1. Написать процедуры/функции с использованием транзакций и явных блокировок.
1.1. Процедура для записи в очередь CreateRecordQueue с параметром CustomerFullName:
- ищет в таблице Queue на текущий момент (интересны только сегодняшние записи) OperatorID, у которого Operators.IsWorking = 1 и с наименьшим количеством не вызванных клиентов в очереди;
- определяет следующий QueueNumber; 
- после чего, добавляет запись в Queue: OperatorID (найденный),  RegistrationDate (текущее время с датой) CustomerFullName (параметр),  QueueNumber (вычисленный);
- возвращает данные для талона:  CustomerFullName, QueueNumber, OperatorPlace, (по желанию можно вернуть количество людей в очереди на текущий момент).
1.2. Процедура, оповещающая, что клиент обслужен, EndOperatorService с параметром OperatorID:
- устанавливает в таблице Operators.IsWorking = 1 для данного OperatorID;
- находит первую запись с вызванным, но не обслуженным клиентом (StartServiceDate не NULL, а EndServiceDate – NULL), если не находит – выходим;
- устанавливает в этой записи EndServiceDate текущее время с датой.

2. Написать процедуры/функции с использованием транзакций и явных блокировок.
2.1. Процедура  для вызова клиента StartOperatorService с параметром OperatorID:
- устанавливает в таблице Operators.IsWorking = 1 для данного OperatorID;
- проверяет, не ли в таблице Queue записи с вызванным, но не обслуженным клиентом (StartServiceDate не NULL, а EndServiceDate – NULL), если есть, то вызывает исключение, из которого должно быть понятно какой CustomerFullName и QueueNumber не обслужен.
- далее ищет в таблице Queue запись с первым в очереди на сегодня не вызванным клиентом, если не находит – выходим;
- устанавливает в этой записи StartServiceDate текущее время с датой;
- возвращает данные для вызова клиента на табло: CustomerFullName, QueueNumber, OperatorPlace.
2.2. Процедура для окончания работы оператора с клиентом EndOperatorWorking с параметром OperatorID:
- на всякий случай проверяет, что для данного OperatorID  в таблице Operators.IsWorking = 1, если 0 – выходим;
- проверяет нет ли у данного OperatorID на сегодня записей в очереди с вызванными, но не обслуженными клиентами, если есть, то вызывает исключение, по тексту которого должно быть понятно какой  CustomerFullName и QueueNumber не обслужен;
- устанавливает в таблице Operators.IsWorking = 0 для данного OperatorID.

## Contributors:
- Vladislave:) [hawwyo](https://github.com/hawwyo)
