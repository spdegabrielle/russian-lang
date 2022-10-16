#lang scribble/manual

@(require 1/lang scribble/example (for-label 1/all-base))

@title{Русский язык программирования Ади́на}
@author[(author+email "Клочков Роман" "kalimehtar@mail.ru")]

@defmodulelang["1" #:module-path 1/all-base #:packages ("russian-lang")]

Это руководство описывает русскоязычный язык программирования, основанный
на идеях из расширения синтаксиса Scheme @hyperlink["http://www.dwheeler.com/readable/"]{readable}.

Название Ади́на взято из названия симпатичного
@hyperlink["https://www.plantarium.ru/page/view/item/67917.html"]{кустарника}.

Семантика языка на данный момент полностью унаследована от Racket,
вплоть до полной обратной совместимости: из этого
языка можно вызывать любые функции и синтаксические конструкци Racket,
а из Racket можно вызывать модули на этом языке.

Для включения синтаксиса данного языка просто укажите в модуле Racket в первой строке

@nested[#:style 'code-inset]{
  #lang 1
}

или

@codeblock|{
  #!1
}|

Второй вариант рекомендуется при использовании русского языка для написания программы.

@section[#:tag "like Racket"]{Отличия от Racket}

Эта глава предназаначена для тех, кто умеет программировать на Scheme и/или Racket. Остальные
могут её пропустить и перейти к следующей.

На Адине можно писать как на Racket с упрощённым синтаксисом. Обратная совместимость
поддерживается почти полностью,
за исключением строчных комментариев и квадратных и фигурных скобок. Если в Racket
использовалась «;», то здесь для строчных комментариев необходимо использовать
«--», так как «;» используется в других синтаксических конструкциях, которые будут описаны ниже.
Квадратные и фигурные скобки также нельзя использовать вместо круглых,
так как они несут другой синтаксический смысл.

То есть, например, программа

@codeblock|{
  #!1
  (letrec ((is-even? (lambda (n)
                       (or (zero? n)
                           (is-odd? (sub1 n)))))
           (is-odd? (lambda (n)
                      (and (not (zero? n))
                           (is-even? (sub1 n))))))
    (is-odd? 11))
}|

Будет также, как и в Racket, возвращать #t. Но этот язык позволяет сделать списки, из которых
состоит прорамма на Racket, читабельней.
В нём структуру списка можно обозначить не скобками, а отступами. Список можно записать как
@codeblock{
  #!1
  список 1 2 3 4 5 6
}
или как
@codeblock{
 #!1
 список 1 2 3 4
    5
    6
}
Функция @racket[список] синоним функции @racket[list].

Если на одной строке есть несколько элементов, разделённых пробельными символами, то это список.
Если следующая строка начинается с большего отступа, чем текущая, то это элемент ---
продолжение списка, если отступ текущей строки равен отступу предыдущей,
которая является элементом списка, то эта строка также элемент того же списка.

Для иллюстрации запишу (список 1 2 (список 3 4) 5 (список 6 (список 7 8)))
@codeblock{
  #!1
  список 1 2
    список 3 4
    5
    список 6
      список 7 8
}

Также есть специальная конструкция для списков, первым элементом которых тоже является список.
В этом случае длядополнительного отступа можно использовать «;». Либо её же можно использовать
для разделения списка на подсписки.

Например
@codeblock{
  (let ((x 1) (y 2))
    (f x y))
}
можно записать как
@codeblock{
  #!1
  let
    ;
      x 1
      y 2
    f x y
}
или как
@codeblock{
  #!1
  let (x 1; y 2)
    f x y
}

Синтаксическое правило выглядит так: если в списке встречается «;», то список разделяется на
подсписки, как если бы
вместо «;» был перенос строки с сохранением отступа.

Таким образом, последовательности элементов «x 1» и «y 2» становятся вложенными списками.

Запишем предыдущий пример, описывая структуру программы отступами
@codeblock|{
  #!1
  letrec
    ;
      is-even?
        lambda (n)
          or
            zero? n
            is-odd?
              sub1 n
      is-odd?
        lambda (n)
          and
            not
              zero? n
            is-even?
              sub1 n
    is-odd? 11
}|

Есть ещё одна синтаксическая конструкция, заимствованная из Haskell, позволяющая сократить
количество строк не добавляя скобок. Символ «$» показывает, что
элементы справа от него являются списком, который должен быть подставлен на место этого символа.

(список 1 2 (список 3 4) 5 (список 6 (список 7 8))) теперь можно записать как
@nested[#:style 'code-inset]{@verbatim{
  #!1
  список 1 2
    список 3 4; 5
    список 6 $ список 7 8
}}

А пример из Racket как
@codeblock|{
  #!1
  letrec
    ;
      is-even? $ lambda (n)
        or
          zero? n
          is-odd? $ sub1 n
      is-odd? $ lambda (n)
        and
          not $ zero? n
          is-even? $ sub1 n
    is-odd? 11
}|

Таким образом получаем наглядное представление программы, которое не перегружено скобками.

Для упрощения чтения программы также добавлено ещё несколько синтаксических конструкций,
которые позволяют сделать текст программы
более похожим на широко распространённые языки программирования.

Если перед скобкой нет пробела, то включается особый алгоритм обработки. Для круглой скобки
элемент перед скобкой добавляется в голову списка.
Элементы внутри спиcка можно (но не обязательно) разделять при помощи «;».

(список 1 2 (список 3 4) 5 (список 6 (список 7 8))) можно выразить как
@nested[#:style 'code-inset]{@verbatim{
#!1
список(1; 2; список 3 4; 5; список 6 $ список 7 8)
}}

Так можно записывать в одну строку вызовы функций с аргументами, которые являются вызовами
функций. Кроме того такитм образом удобно вызывать каррированные функции
Вместо (((f 5) 6) 7) будет f(5)(6)(7)

Для квадратной скобки конструкция преобразуется в инструкция
доступа к коллекции (массиву/списку/хэшу).

Вместо (vector-ref a 5) можно просто писать a[5].
А вместо (vector-ref (vector-ref a 5) 6) --- a[5][6]

Для фигурной скобки конструкция даёт возможность вызвать методы объекта.

@racket[(send window show #t)] можно записать как @racket[window{show #t}]. также можно использовать
несколько вызовов как в @racket[send+].

@codeblock{
(send* (new point%)
 (move-x 5)
 (move-y 7)
 (move-x 12))
}

преобразуется в
@nested[#:style 'code-inset]{@verbatim{
#!1
new(point%){move-x 5; move-y 7; move-x 11}
}}
или
@nested[#:style 'code-inset]{@verbatim{
#!1
new(point%){move-x(5) move-y(7) move-x(11)}
}}

Для удобства работы с арифметикой реализованы приоритеты бинарных операций.
Если в списке обнаружена бинарная операция, то она становится в голову списка и получает элементы
до и после неё как два аргумента-списка. Операцией считается любой индентификатор,
который состоит только из !#$%&⋆+./<=>?@"@"^~:*- и не равен «...». Любой другой идентификатор можно
сделать оператором добавив перед и после него символы «^». Например, @racket[(2 ^cons^ 3)]
то же самое, что @racket[(cons 2 3)].

Если надо, чтобы операция оставалась аргументом, то пишите её как список из точки и операции.
Например, если надо написать @racket[(list + 3)], то можно написать
@codeblock{
#!1
list (. +) 3
}

Оператор равенства реализован как == (вместо @racket[equal?]) и === (вместо @racket[eqv?]),
также реализованы // (как @racket[quotient]), /= (неравно), ||, &&, % (как @racket[remainder]).

@racket[(+ (vector-ref a 5) (* 2 (hash-ref h 'key)))] можно написать как
@codeblock{
#!1
a[5] + 2 * h['key]
}

Внимание: пробелы вокруг операций обязательны, так как @racket[2*h],
например, является нормальным именем переменной.

При помощи операций вышеупомянутый пример можно записать так:
@codeblock|{
#!1           
letrec
  ;
    is-even? $ lambda (n)
      n === 0 || is-odd? (n - 1)
    is-odd? $ lambda (n)
      n /= 0 && is-even? (n - 1)
  is-odd? 11
}|

@section[#:tag "essentials"]{Основы языка}

Программа состоит из команд. Команда может быть вызовом функции, синтаксической конструкцией или
определением переменной.
Первая строка в программе определяет используемый язык программирования и является строкой «#!1».

Например, эта программа запрашивает имя и выводит приветствие:
@codeblock|{
#!1
вывести "введите имя: "
имя = прочитать-строку()
вывести
  "Привет, " ++ имя
}|

@subsection[#:tag "simple values"]{Простые значения}

Значения языка программирования включают числа, логические значения, строки и массивы байтов.
В DrRacket и документации они выделены зелёным цветом.

@defterm{Числовые значения} могут быть записаны как целые произвольной длины, в виде десятичных
или простых дробей, с экспонентой или мнимой частью.
@racketblock[
10      2.5
1/3     1.02e+13
5+6i    12345678123456781234567812345678
]

Бесконечные целые и простые дроби позволяют выполнять арифметические операции без потери точности
и риска переполнения. Числа с десятичной точкой или экспонентой являются
вещественными числами двойной точности и хранят только 15-17 знаков.

@defterm{Логические значения} — это @racketvalfont{истина} и @racketvalfont{ложь}. При проверках
в логических операциях любое значение, не равное
@racketvalfont{ложь} трактуется как истина.

@defterm{Строчные значения} записываются между двойными кавычками. Для записи кавычк используется
последовательность символов «\"», для записи символа «\» --- «\\». Все остальные символы
Юникода можно писать как есть.

@racketblock[
"Привет!"
"Автомобиль \"Москвич\""
"你好"
]

Когда константа выводится в окне интерпретатора, как правило, она имеет тот же вид, в котором она
была введена, но иногда при выводе происходит нормализация.
В окне интерпретатора и в документации результат вычислений выводится синим, а не зелёным, чтобы
было видно, где результат, а где введённое значение.

@examples[#:label "Примеры:"
 (eval:alts (unsyntax (racketvalfont "1.0000")) 1.0)
 (eval:alts (unsyntax (racketvalfont "\"\\u0022ok\\u0022\"")) "\u0022ok\u0022")]

@subsection[#:tag "expressions"]{Выражения}

Выражения записываются в виде последовательности слов, разделённых пробельными символами.
Слово может быть оператором, если состоит только из символов «!#$%&⋆+./<=>?@"@"^~:*-» кроме «...»
или начинается и заканчивается на «^». Примеры операторов: +, -, ^пара^.
Если оператор начинается и закачничвается на «^», то он вызывает функцию по имени между «^»
со своими аргументами.
Например, @racket[(2 ^пара^ 3)] то же самое, что @racket[(пара 2 3)].

Также операторы (кроме @racket[=] и @racket[?] описанных ниже) автоматически объединяют слова
перед и после оператора в команды. Например @racket[(список 2 3 ++ список 4 5 6)] то же самое,
что @racket[(++ (список 2 3) (список 4 5 6))].

Если в выражении нет операторов, то первое слово определеяет синтаксис выражения.
Если первое слово --- функция, то остальные слова --- аргументы этой функции.
@examples[#:label "Примеры:"
(eval:alts (unsyntax (elem (racket список) (racketvalfont " 1 2 3"))) '(1 2 3))
(eval:alts (unsyntax (elem (racket пара) (racketvalfont " 5 6"))) '(5 . 6))
]

Если какие-то аргументы также являются функциями, то можно использовать отступы
@examples[#:label #f
(eval:alts (unsyntax (elem (racket список) (racketvalfont " 1 2 3 4")
                           (linebreak) (hspace 4) (racket список) (racketvalfont " 5 6")
                           (linebreak) (hspace 4) (racketvalfont "7")))
           '(1 2 3 (5 6) 7))
]

После любого элемента строки можно следующие элементы писать по одному на строке.
Отступ этих элементов должен быть больше отступа текущей строки и одинаков.
Если элемент состоит из одного слова, он является значением, если же из нескольких,
то командой, результат которой будет значением элемента.

Если по какой-либо причине выписывать последние элементы по одному на строке некрасиво,
например, если первый аргумент является командой, а остальные простыми значениями,
то можно функция писать в виде «функция(аргумент1 аргумент2 ...)».
Предыдущий пример тогда будет выглядеть как
@examples[#:label #f
(eval:alts (unsyntax (elem (racket список)
                           (racketvalfont " 1 2 3 4 ")
                           (racket список) (racketvalfont "(5 6) 7")))
           '(1 2 3 (5 6) 7))
]
Следует запомнить, что в таком случае скобка должна идти сразу за именем функции.

Ещё один альтернативный способ записи: в стиле лиспа. Можно просто взять всю команду в скобки:
@examples[#:label #f
(eval:alts (unsyntax (elem (racket список)
                           (racketvalfont " 1 2 3 4 (")
                           (racket список) (racketvalfont " 5 6) 7")))
           '(1 2 3 (5 6) 7))
]
и тогда внутри скобок переносы и отступы игнорируются.

Если строка очень длинная, то можно перед переносом вставить символ «\», тогда перенос
не будет нести синтаксического смысла.

Выбор способа написания определяется удобством чтения. При вводе в окно интерпретатора
ввод заканчивается после пустой строки, так как до этого возможно продолжение команды.

Также есть ещё две особые синтаксических конструкции: «список 1 2 3 4 список(5 6)» можно
записать как «список 1 2 3 4 $ список 5 6», то есть оператор «$» позволяет
слова после неё выделить в отдельную команду. Чтобы объединить несколько коротких команд
или значений в одну строку в одну, можно использовать оператор «;».
@examples[#:label "Пример:"
(eval:alts (unsyntax (elem (racket список) (racketvalfont " 1 2 3 4")
                           (linebreak) (hspace 4) (racket список) (racketvalfont " 5 6")
                           (linebreak) (hspace 4) (racketvalfont "7; ") (racket список)
                           (racketvalfont " 8; 9")))
           '(1 2 3 4 (5 6) 7 (8) 9))
]
Можно заметить, что перед «;» пробел не обязателен.

@subsection[#:tag "basic definitions"]{Основы определений}

Определение в форме
@racketblock[
<идентификатор> = <выражение>
]
cвязывает <идентификатор> с результатом вычисления выражения, а в форме
@racketblock[
<идентификатор>(<идентификатор> ...) = <выражение> <выражение> ...
]
связывает первый <идентификатор> с функцией, которая принимает параметры, именованные остальными
идентификаторами. В случае функции выражения являются телом функции. При вызове функции
её результатом является результат последнего выражения. Если параметры есть, то скобки можно не
писать, а просто перечислить параметры через пробел, как описано в предыдущем разделе.

При разборе определения функции есть исключение синтаксиса: в этом случае оператор @racket[=]
объединяет слова в команду только с левой стороны, иначе в функции могла бы быть только одна команда.
Поэтому даже если функция состоит из одной команды, она обязательно должна быть выделена или
скобками или переносом.

@examples[#:label "Примеры:"
(eval:alts (unsyntax (elem (racketidfont "часть ") (racket =) (racketvalfont " 3"))) (void))
(eval:alts (unsyntax (elem (racketidfont "кусок строка ") (racket =) (linebreak) (hspace 4)
                                         (racket подстрока)
                           (racketvalfont " строка 0 часть"))) (void))
(eval:alts (unsyntax (racketvalfont "часть")) 3)
(eval:alts (unsyntax (racketvalfont "кусок \"три символа\"")) "три")
]

Определение функции может включать несколько выражений. Тогда значение последнего выражения будет
значением функции, а остальные выражения вычисляются только для побочных эффектов, таких как вывод.
@examples[#:label "Примеры:"
(eval:alts (unsyntax (elem (racketidfont "испечь вкус " (racket =))
                           (linebreak) (hspace 4)
                           (racket вывести) (hspace 1) (racket "разогрев печи...\n")
                           (linebreak) (hspace 4)
                           (racket вкус) (hspace 1) (racket ++) (hspace 1) (racket " пирог")))
           (void))
(eval:alts (unsyntax (elem (racketidfont "испечь") (hspace 1) (racket "вишнёвый")
                           (linebreak) (racketoutput "разогрев печи...")))
           "вишнёвый пирог")
]

Если попробовать записать функцию в одну строку, то получится
@examples[#:label "Примеры:"
(eval:alts (unsyntax (elem (racketidfont "не-печётся вкус ") (racket =) (hspace 1)
                           (racket вкус) (hspace 1) (racket ++) (hspace 1) (racket " пирог")))
           (void))
(eval:alts (unsyntax (elem (racketidfont "не-печётся") (hspace 1) (racket "вишнёвый")))
           " пирог")
]

Это потому, что определение прочитано как
@codeblock|{
не-печётся вкус =
  вкус
  ++
  " пирог"
}|
и последовательно выполняется: вычисление значения переменной, значения операции и строки.
Последнее возвращается как результат функции.

И, на самом деле, определение функции также как и определение не функции всего лишь связывает
идентификатор с значением и этот идентификатор
можно тоже использовать как выражение.

@examples[#:label "Примеры:"
(eval:alts #,(racketidfont "кусок") (eval:result (racketresultfont "#<функция:кусок>") "" ""))
(eval:alts #,(racketidfont "подстрока") (eval:result (racketresultfont "#<функция:подстрока>") "" ""))
]

@subsection[#:tag "identifiers"]{Идентификаторы}

Синтакисис для идентификаторов масимально свободный. В них могут быть использованы любые символы
кроме пробелов, скобок, кавычек, апострофов, точки с запятой, запятой, решётки, вертикальной черты
и обратной косой черты за исключением последовательностей, являющихся числовыми константами.
Более того, можно вводить идентификатор между вертикальным чертами, тогда
допустимы вообще любые символы кроме вертикальной черты.

Примеры идентификаторов:
@codeblock|{
не-печётся
++
=
Проверка
проверка/вывод
а+б
с+1
|идентификатор со спецсимволами ( ) [ ] { } " , ' ` ; # \|
}|

@subsection[#:tag "function call"]{Вызовы функций}

Мы уже видели много вызовов функций. Синтаксис вызова
@codeblock|{
(<имя> <выражение>*)
}|
где количество выражений определяется количеством аргументов функции с именем <имя>.

Разумеется, при записи с начала строки скобки можно опустить.

Язык Адина предопределяет множество функций, таких как @racket[подстрока] и @racket[добавить-строки].
Ниже будут ещё примеры.

В коде примеров в документации использования предопределённых имён оформлены ссылками на
документацию. Таким образом можно присто щёлкнуть по имени функции и получить полную информацию о
её использовании.

@examples[#:label #f
(eval:alts (unsyntax (elem (racket добавить-строки) (hspace 1) (racket "рос") (hspace 1)
                           (racket "сель") (hspace 1) (racket "торг")
                           (racketcommentfont "  -") (racketcommentfont "- добавить строки")))
            "россельторг")
(eval:alts (unsyntax (elem (racket подстрока) (hspace 1) (racket "паровоз") (hspace 1)
                           (racket 0) (hspace 1) (racket 3)
                           (racketcommentfont "  -") (racketcommentfont "- извлечь подстроку")))
           "пар")
(eval:alts (unsyntax (elem (racket строка?) (hspace 1) (racket "это строка")
                           (racketcommentfont "  -") (racketcommentfont "- распознать строку")))
           (eval:result (racketvalfont "истина")))
(eval:alts (unsyntax (elem (racket строка?) (hspace 1) (racket 42)))
           (eval:result (racketvalfont "ложь")))
(eval:alts (unsyntax (elem (racket корень) (hspace 1) (racket 16)
                           (racketcommentfont "  -")
                           (racketcommentfont "- вычислить квадратный корень")))
           (sqrt 16))
(eval:alts (unsyntax (elem (racket корень) (hspace 1) (racket -16)))
           (sqrt -16))
(eval:alts (unsyntax (elem (racket +) (hspace 1) (racket 1) (hspace 1) (racket 2)
                           (racketcommentfont "  -")
                           (racketcommentfont "- сложить")))
           (+ 1 2))
(eval:alts (unsyntax (elem (racket -) (hspace 1) (racket 2) (hspace 1) (racket 2)
                           (racketcommentfont "  -")
                           (racketcommentfont "- вычесть")))
           (- 2 1))
(eval:alts (unsyntax (elem (racket <) (hspace 1) (racket 2) (hspace 1) (racket 2)
                           (racketcommentfont "  -")
                           (racketcommentfont "- сравнить")))
           (eval:result (racketvalfont "ложь")))
(eval:alts (unsyntax (elem (racket >=) (hspace 1) (racket 2) (hspace 1) (racket 2)))
           (eval:result (racketvalfont "истина")))
(eval:alts (unsyntax (elem (racket число?) (hspace 1) (racket "это не число")
                           (racketcommentfont "  -")
                           (racketcommentfont "- распознать число")))
           (eval:result (racketvalfont "ложь")))
(eval:alts (unsyntax (elem (racket число?) (hspace 1) (racket 1)))
           (eval:result (racketvalfont "истина")))
(eval:alts (unsyntax (elem (racket ==) (hspace 1) (racket 6) (hspace 1) (racket "шесть")
                           (racketcommentfont "  -")
                           (racketcommentfont "- сравнить что угодно")))
           (eval:result (racketvalfont "ложь")))
(eval:alts (unsyntax (elem (racket ==) (hspace 1) (racket 6) (hspace 1) (racket 6)))
           (eval:result (racketvalfont "истина")))
(eval:alts (unsyntax (elem (racket ==) (hspace 1) (racket "шесть") (hspace 1) (racket "шесть")))
           (eval:result (racketvalfont "истина")))]

Если функция является оператором, то её можно писать вторым словом.

@examples[#:label "Примеры:"
(eval:alts (unsyntax (elem (racket 1) (hspace 1) (racket +) (hspace 1) (racket 2)
                           (racketcommentfont "  -")
                           (racketcommentfont "- сложить")))
           (+ 1 2))
(eval:alts (unsyntax (elem (racket 2) (hspace 1) (racket -) (hspace 1) (racket 1)
                           (racketcommentfont "  -")
                           (racketcommentfont "- вычесть")))
           (- 2 1))
(eval:alts (unsyntax (elem (racket 2) (hspace 1) (racket <) (hspace 1) (racket 1)
                           (racketcommentfont "  -")
                           (racketcommentfont "- сравнить")))
           (eval:result (racketvalfont "ложь")))
(eval:alts (unsyntax (elem (racket 2) (hspace 1) (racket >=) (hspace 1) (racket 1)))
           (eval:result (racketvalfont "истина")))
(eval:alts (unsyntax (elem (racket 6) (hspace 1) (racket ==) (hspace 1) (racket "шесть")
                           (racketcommentfont "  -")
                           (racketcommentfont "- сравнить что угодно")))
           (eval:result (racketvalfont "ложь")))
(eval:alts (unsyntax (elem (racket 6) (hspace 1) (racket ==) (hspace 1) (racket 6)))
           (eval:result (racketvalfont "истина")))
(eval:alts (unsyntax (elem (racket "шесть") (hspace 1) (racket ==) (hspace 1) (racket "шесть")))
           (eval:result (racketvalfont "истина")))]

@subsection[#:tag "conditionals expressions"]{Условные конструкции с @racket[если] и
 операторами @racket[?], @racket[&&] и @racket[||]}



@section[#:tag "reference"]{Справочник}

@subsection[#:tag "definitions"]{Определения}

@defform*[#:kind "синтаксис" #:id =
   ((идентификатор = выражение)
    (#,(racketidfont "значения") идентификатор ... = выражение)
    (заголовок(параметры) = команда ... выражение))
   #:grammar [(заголовок идентификатор (заголовок параметры))
              (параметры (code:line параметр ...)
                         (code:line параметр ... @#,racketparenfont{.} параметр-оставшихся))
              (параметр идентификатор [идентификатор выражение] (code:line ключ идентификатор)
                        (code:line [ключ идентификатор выражение]))
              ]]{
   Первая форма связывает идентификатор с результатом вычисления выражжения.
 Вторая позволяет одновременно связать несколько идентификаторов с значениями
(выражение должно в этом случае возвращать необходимое количество значений).
 Третья связывает идентификатор с функцией, здесь особым образом обрабатывается оператор: каждый
 элемент после @racket[=] считается отдельной командой. То есть, если надо сделать
 функцию из одного выражения, обязательно после @racket[=] делать перенос и отступ.}

@subsection[#:tag "logicals"]{Логические выражения}

@defproc[#:kind "функция" (логический? [параметр любой])
         логический?]{Возвращает @racketvalfont{истина}, если @racket[параметр]
 @racketvalfont{истина} или @racketvalfont{ложь}, в противном случае возвращает
 @racketvalfont{ложь}.}

@defproc[#:kind "функция" (== [параметр любой] ...)
         логический?]{Возвращает @racketvalfont{истина}, если @racket[параметр]ы
 равны. Списки и массивы считаются равными, если равны их элементы.}

@subsection[#:tag "conditionals"]{Условия}

@defform[#:kind "синтаксис" (? условие выражение-если-истина выражение-если-ложь)
         #:contracts ([условие логический?])]{Если @racket[условие] истинно,
 выполняет @racket[выражение-если-истина] иначе выполняет @racket[выражение-если-ложь].
Возвращает результат выполненного выражения.

При использовании как оператор не объединяет в одно выражение слова справа от себя.}

@defform[#:kind "синтаксис" (&& выражение ...)]{Выполняет выражения слева направо, пока
одно из них не вернёт ложь или они не закончатся.
 Возвращает результат последнего выполненного выражения.}

@defform[#:kind "синтаксис" (|| выражение ...)]{Выполняет выражения слева направо, пока
одно из них не вернёт истину или они не закончатся.
 Возвращает результат последнего выполненного выражения.}

@subsection[#:tag "numbers"]{Числа}

@defproc[#:kind "функция" (число? [параметр любой])
         логический?]{Возвращает истину, если @racket[параметр] является числом.}

@defproc[#:kind "функция" (корень [число число?])
         число?]{Возвращает главный (для положительных вещественных совпадает с арифметическим)
 квадратный корень из значения параметра @racket[число].
 Результат точный, если @racket[число] точное и квадратный корень из него рациональный.}

@subsection[#:tag "lists"]{Списки}

@defproc[#:kind "функция" (список? [параметр любой])
         логический?]{Возвращает истину, если @racket[параметр] является списком.}

@defproc[#:kind "функция" (список [параметр любой] ...)
         список?]{Возвращает список из произвольных значений.}

@defproc[#:kind "функция" (пара? [параметр любой])
         логический?]{Возвращает истину, если @racket[параметр] является парой.}

@defproc[#:kind "функция" (пара [параметр1 любой] [параметр2 любой])
         пара?]{Возвращает пару из переданных параметров. Если второй параметр список,
 то возвращаемое значение тоже список.}

@defproc[#:kind "функция" (++ [параметр (один-из список? строка? массив?)] ...)
         (один-из список? строка? массив?)]{Возвращает сцепку переданных параметров.
Создаётся новая изменяемая коллекция достаточного размера для всех элементов параметров,
затем все элементы всех параметров последовательно копируются в новую коллекцию.
 Тип параметров должен быть одинаковый.}

@subsection[#:tag "strings"]{Строки}

@defproc[#:kind "функция" (строка? [параметр любой])
         логический?]{Возвращает истину, если @racket[параметр] является строкой.}

@defproc[#:kind "функция" (длина-строки [строка строка?])
         целое-неотрицательное?]{Возвращает длину строки в символах.}

@defproc[#:kind "функция" (подстрока [строка строка?] [начало целое-неотрицательное?]
                                     [конец целое-неотрицательное? (длина-строки строка)])
         строка?]{Возвращает подстроку из параметра @racket[строка] с позиции @racket[начало]
 по позицию @racket[конец].}

@defproc[#:kind "функция" (добавить-строки [строка строка?] ...)
         строка?]{Возвращает сцепку строк.
Создаётся новая изменяемая строка достаточного размера,
затем все знаки всех строк последовательно копируются в новую.}

@subsection[#:tag "inout"]{Ввод-вывод}

@defproc[#:kind "функция" (вывести [параметр любой] [вывод порт? (текущий-порт-вывода)])
         пусто?]{Выводит значение @racket[параметра] в @racket[вывод].}

@defproc[#:kind "функция" (прочитать-строку)
         строка?]{Читает строку из стандартного ввода.}
