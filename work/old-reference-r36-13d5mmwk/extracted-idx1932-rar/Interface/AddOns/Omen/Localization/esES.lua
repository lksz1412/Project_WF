--  Translation courtesy of Ben (Aesyl - US Tanaris)
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Omen", "esES", true)
if not L then return end

-- Main Omen window
L["<Unknown>"] = "<Desconocido>"
L["Omen Quick Menu"] = "Omen Menu Rápido"
L["Use Focus Target"] = "Usar Objetivo de Foco"
L["Test Mode"] = "Modo para Prueba"
L["Open Config"] = "Abrir Configuración"
L["Hide Omen"] = "Ocultar Omen"
L["Name"] = "Nombre"
L["Threat [%]"] = "Amenaza [%]"
L["TPS"] = "APS"
L["Toggle Focus"] = true

-- Warnings
L["|cffff0000Error:|r Omen cannot use shake warning if you have turned on nameplates at least once since logging in."] = "|cffff0000Error:|r Omen no puede usar el aviso de temblar si usted ha activado las placas de nombre al menos una vez desde ha entrado."
L["Passed %s%% of %s's threat!"] = "¡Has pasado un %s%% del %s de amenaza!"

-- Config module titles
L["General Settings"] = "Opciones Generales"
L["Profiles"] = "Perfiles"
L["Slash Command"] = "Comando de Barra"

-- Config strings, general settings section
L["OMEN_DESC"] = "Omen es un metro ligero de amenaza que le muestra la amenaza de mobs con que usted está en combate. Puede cambiar cómo Omen se aparece y funciona, y configura perfiles diferentes por cada carácter"
L["Alpha"] = "Alfa"
L["Controls the transparency of the main Omen window."] = "Controla la transparencia de la ventana primaria de Omen."
L["Scale"] = "Escala"
L["Controls the scaling of the main Omen window."] = "Controla la escalada de la ventana primaria de Omen."
L["Autocollapse"] = "Desplomarse Automáticamente"
L["Collapse to show a minimum number of bars"] = "Desplomarse para mostrar un número minimo de barras."
L["Lock Omen"] = "Cerrar Omen"
L["Locks Omen in place and prevents it from being dragged or resized."] = "Cierra Omen en sitio y lo evita que arrastrar o cambiar la talla."
L["Autocollapse Options"] = "Opciones de Desplomarse Automáticamente"
L["Grow bars upwards"] = "Barras crecen hacia arriba"
L["Hide Omen on 0 bars"] = "Ocultar Omen cuándo hay 0 barras"
L["Hide Omen entirely if it collapses to show 0 bars"] = "Ocultar Omen completamente si se desploma para mostrar 0 barras"
L["Max bars to show"] = "Máx. barras para mostrar"
L["Max number of bars to show"] = "Número máximo de barras para mostrar"
L["Background Options"] = "Opciones del Fondo"
L["Background Texture"] = "Textura del Fondo"
L["Texture to use for the frame's background"] = "Textura para usar por el fondo del marco"
L["Border Texture"] = "Textura del Marco"
L["Texture to use for the frame's border"] = "Textura para usar por el borde del marco"
L["Background Color"] = "Color del Fondo"
L["Frame's background color"] = "Color del fondo del marco"
L["Border Color"] = "Color del Borde"
L["Frame's border color"] = "Color del borde del marco"
L["Tile Background"] = "Tejar el Fondo"
L["Tile the background texture"] = "Textur für den Hintergrund in Kacheln anzeigen"
L["Background Tile Size"] = "Größe der Kacheln des Hintergrundes"
L["The size used to tile the background texture"] = "La talla usado para tejar la textura del fondo"
L["Border Thickness"] = "Grosor del Borde"
L["The thickness of the border"] = "El grosor del borde"
L["Bar Inset"] = "Recuadro de la Barra"
L["Sets how far inside the frame the threat bars will display from the 4 borders of the frame"] = "Controla a qué distancia dentro del marco las barras de amenaza mostrarán de los 4 bordes del marco"

-- Config strings, title bar section
L["Title Bar Settings"] = "Opciones de la Barra de Título"
L["Configure title bar settings."] = "Configurar opciones de la Barra de Título"
L["Title Bar Height"] = "Altura de la Barra de Título"
L["Height of the title bar. The minimum height allowed is twice the background border thickness."] = "Altura de la Barra de Título. La altura minima permitida es el doble del grosor del borde del fondo."
L["Title Text Options"] = "Opciones del Texto del Título"
L["The font that the title text will use"] = "El fuente que el título usará"
L["The outline that the title text will use"] = "La silueta que el texto del título usará"
L["The color of the title text"] = "El color del texto del título"
L["Control the font size of the title text"] = "Controla la talla del fuente del texto del título"

-- Config strings, show when... section
L["Show When..."] = "Mostrar cuándo..."
L["Show Omen when..."] = "Mostrar Omen cuándo..."
L["Show Omen when any of the following are true"] = "Mostrar Omen cuándo cualquiera de lo siguiente es cierto"
L["You have a pet"] = "Usted ha una mascota"
L["Show Omen when you have a pet out"] = "Mostrar Omen cuándo ha una mascota fuera"
L["You are alone"] = "Usted está solo(a)"
L["Show Omen when you are alone"] = "Mostrar Omen cuándo usted está solo(a)"
L["You are in a party"] = "Usted está en un grupo"
L["Show Omen when you are in a 5-man party"] = "Mostrar Omen cuándo usted está en un grupo de 5 miembros"
L["You are in a raid"] = "Usted está en una banda"
L["Show Omen when you are in a raid"] = "Mostrar Omen cuándo usted está en una banda"
L["You are resting"] = "Usted está descansando"
L["Show Omen when you are resting"] = "Mostrar Omen cuándo usted está descansando"
L["You are in a battleground"] = "Usted está en un campo de batalla"
L["Show Omen when you are in a battleground or arena"] = "Mostrar Omen cuándo usted está en un campo de batalla"
L["You are in a dungeon"] = "Usted está en una instancia"
L["Show Omen when you are in a dungeon (5 man and raid)"] = "Mostrar Omen cuándo usted está en una instancia (de 5 miembros o una banda)"
L["In addition to the above options..."] = "Además de las opciones de arriba..."
L["Only show when in combat"] = "Solamente mostrar cuándo en combate"
L["Turning this on will cause Omen to hide whenever you are not in combat."] = "Esta opción hará que Omen se oculta cuándo usted no está en combate."

-- Config strings, show classes... section
L["Show Classes..."] = "Mostrar Clases..."
L["SHOW_CLASSES_DESC"] = "Mostrar barras de amenaza de Omen por las clases siguientes. Las clases aquí se refieron solamente a las personas quien están en su grupo/banda a excepción de la opción 'No Estar en el Grupo'."
L["Show bars for these classes"] = "Mostrar barras por estes clases"
L["DEATHKNIGHT"] = "Caballero de la muerte"
L["DRUID"] = "Druída"
L["HUNTER"] = "Cazador"
L["MAGE"] = "Mago"
L["PALADIN"] = "Paladín"
L["PET"] = "Mascota"
L["PRIEST"] = "Sacerdote"
L["ROGUE"] = "Pícaro"
L["SHAMAN"] = "Chamán"
L["WARLOCK"] = "Brujo"
L["WARRIOR"] = "Guerrerro"
L["*Not in Party*"] = "*No Estar en el Grupo*"

-- Config strings, bar settings section
L["Bar Settings"] = "Opciones por las Barras"
L["Configure bar settings."] = "Configura las opciones por las barras"
L["Animate Bars"] = "Animar las Barras"
L["Smoothly animate bar changes"] = "Animar Suavamente las Barras"
L["Short Numbers"] = "Números Cortos"
L["Display large numbers in Ks"] = "Mostrar números grandes en Ks"
L["Bar Texture"] = "Textura de la Barra"
L["The texture that the bar will use"] = "La Textura que la barra usará"
L["Bar Height"] = "Altura de la Barra"
L["Height of each bar"] = "Altura de cada barra"
L["Bar Spacing"] = "Espacio de la Barra"
L["Spacing between each bar"] = "Espacio entre cada barra"
L["Show TPS"] = "Mostrar APS"
L["Show threat per second values"] = "Mostrar los valores de amenaza por segundo"
L["TPS Window"] = "Ventana de APS"
L["TPS_WINDOW_DESC"] = "La calculación de amenaza por segundo se basa en una ventana corredera de tiempo real de los X segundos pasados"
L["Show Headings"] = "Mostrar Categorías"
L["Show column headings"] = "Mostrar las categorías sobre de las columnas"
L["Heading BG Color"] = "Color del Fondo de las Categorías"
L["Heading background color"] = "Color del Fondo de las Categorías"
L["Use 'My Bar' color"] = true
L["Use a different colored background for your threat bar in Omen"] = true
L["'My Bar' BG Color"] = true
L["The background color for your threat bar"] = true
L["Bar Label Options"] = "Opciones de Etiqueta de Barra"
L["Font"] = "Fuente"
L["The font that the labels will use"] = "El fuente que las etiquetas usarán"
L["Font Size"] = "Talla de Fuente"
L["Control the font size of the labels"] = "Controla la talla de fuente de las etiquetas"
L["Font Color"] = "Color de Fuente"
L["The color of the labels"] = "El color de las etiquetas"
L["Font Outline"] = "Silueta de Fuente"
L["The outline that the labels will use"] = "La silueta que las etiquetas usarán"
L["None"] = "Nada"
L["Outline"] = "Silueta"
L["Thick Outline"] = "Silueta Gruesa"

-- Config strings, slash command section
L["OMEN_SLASH_DESC"] = "Estes botones ejecutan las mismas funciones como los en el comando de barra /omen"
L["Toggle Omen"] = "Mostrar/Ocultar Omen"
L["Center Omen"] = "Centrar Omen"
L["Configure"] = "Configurar"
L["Open the configuration dialog"] = "Abrir el diálogo de configuración"

-- Config strings, warning settings section
L["Warning Settings"] = "Opciones de Aviso"
L["OMEN_WARNINGS_DESC"] = "Esta sección le permite adaptar cuándo y cómo Omen le notifica si su amenaza es demasiado alto."
L["Enable Sound"] = "Activar Sonido"
L["Causes Omen to play a chosen sound effect"] = "Hacer que Omen pone un sonido escogido"
L["Enable Screen Flash"] = "Activar Destello de Pantalla"
L["Causes the entire screen to flash red momentarily"] = "Hace que la pantalla entera destella rojo brevemente"
L["Enable Screen Shake"] = "Activar Temblar de Pantalla"
L["Causes the entire game world to shake momentarily. This option only works if nameplates are turned off."] = "Hace que el mundo entero del juego tiembla brevemente. Esta opción solamente funciona si placas de nombre son desactivados."
L["Enable Warning Message"] = "Activar Mensaje de Aviso"
L["Print a message to screen when you accumulate too much threat"] = "Mostrar una mensaje a la pantalla cuándo usted acumula demasiada amenaza"
L["Warning Threshold %"] = "Umbral de Aviso %"
L["Sound to play"] = "Sonido para poner"
L["Disable while tanking"] = "Desactivar cuándo usted está el tanque"
L["DISABLE_WHILE_TANKING_DESC"] = "No avisar si Actitud defensiva, Forma de oso, Furia recta o Presencia de Helada"
L["Test warnings"] = "Avisos de Prueba"

-- Config strings, for Fubar
L["Click|r to toggle the Omen window"] = "Haga clic|r para mostrar/ocultar la ventana de Omen"
L["Right-click|r to open the options menu"] = "Haga clic con el botón derecho|r para abrir el menu de opciones"
L["FuBar Options"] = "Opciones de FuBar"
L["Attach to minimap"] = "Adjuntar a la minimapa"
L["Hide minimap/FuBar icon"] = "Ocultar el icono de la minimapa/FuBar"
L["Show icon"] = "Mostrar icono"
L["Show text"] = "Mostrar texto"
L["Position"] = "Posición"
L["Left"] = "Izquierda"
L["Center"] = "Centro"
L["Right"] = "Derecho"

-- FAQ
L["Help File"] = "Ayuda"
L["A collection of help pages"] = "Una colleción de páginas de ayuda"
L["Frequently Asked Questions"] = "Preguntas Frecuentes"
L["Warrior"] = "Guerrerro"

L["GENERAL_FAQ"] = [[
|cffffd200Cómo difiere Omen3 de Omen2?|r

Omen3 contar completamente con el API de amenaza de Blizzard y eventos de amenaza. No trata a calcular o extrapolar la amenaza a diferencia de Omen2.

Omen2 era lo que llamábamos la biblioteca Threat-2.0. Esta biblioteca era responsable por observar el diario de combate, hechizando, ventajas, desventajas, actitudes, talentos y modificadores de equipo para calcular la amenaza de cada individual. La amenaza se calculaba basado en lo que estaba sabido o approximado de conductas observadas. Muchas capacidades como rechazas se basaban en suposiciones.

La biblioteca Threat-2.0 también incluía communicación para transmtir su amenaza al resto de la banda mientras que usaban Threat-2.0 también. Esta información estaba usado para dar una muestra de información de amenaza incluyendo la banda entera.

Desde parche 3.0.2, Omen ya no hace estas cosas y una biblioteca de amenaza ya no es necesario. Omen3 usa el monitor de amenaza de Blizzard para obtener los valores exactos de la amenaza de cada miembro. Esto significa que Omen3 no ha ninguna necesidad por sincronización de datos, analizando del diario de combate o adivinar. Esto resulta en un aumento significativo en rendimiento con respecto a tráfico de red, tiempo de CPU y memoria usado. La implementación de módulos por jefes específicos ya no es necesario.

Además esta implementación nueva permite la addición de la amenaza de NPCs. Sin embargo, hay desventajas; actualizados son menos frecuentes, detallas de amenaza no pueden estar obtenido a menos que alguien en su banda estén apuntando al mob y no es posible obtener amenaza de un mob con que usted no es en combate.

|cffffd200Cómo hago que Omen3 se parece como Omen2?|r

Cambie la Textura de Fondo y Textura de Borde a Blizzard Tooltip, cambie el Color de Fondo a negro (por arrastrar abajo la barra de luminosidad), y el Color de Borde a azul.

|cffffd200Por qué no muestra la amenaza en un mob cuándo lo apunto, aun cuando el es en combate?|r

El API de amenaza de Blizzard no devuelve datos de amenaza de algo mob con que usted no es en combate directamente. Creemos que esto es un esfuerzo para reducir tráfico de red.

|cffffd200Se sincroniza Omen3 o analiza el diario de combate?|r

No. Omen3 no trata sincronizarse o analizar el diario de combate. En este momento no hay ninguna intención para hacer así.

|cffffd200Los actualizados de amenaza son lentos...|r

Omen3 actualiza los valores de amenaza que usted ve cuando Blizzard los actualiza.

|cffffd200Dónde puedo informar sobre errores o dar sugerencias?|r

http://forums.wowace.com/showthread.php?t=14249

|cffffd200Quién escribió Omen3?|r

Xinhuan (Blackrock US Alliance).
]]
L["WARRIOR_FAQ"] = [[Lo siguiente información está obtenido de |cffffd200http://www.tankspot.com/forums/f200/39775-wow-3-0-threat-values.html|r Oct 2nd 2008 (crédito a Satrina). Los números son por un carácter de nivel 80.

|cffffd200Modificadores|r
Actitud de batalla ________ x 80
Actitud rabiosa _____ x 80
Maestría táctica _____ x 121/142/163
Actitud defensiva _____ x 207.35

Nota que en nuestros estimaciones originales (que usamos ahora en WoW 2.0), comparábamos 1 daño a 1 amenaza, y usábamos 1.495 para representar el modificador de actitud+desafío multiplicador. Ahora vemos que el método de Blizzard es para usar el multiplicador sin decimales, así en 2.x habría estado x149 (quizás x149.5); es x207 (quizás 207.3) en 3.0. Supongo que esto es para permitir el transporte de números enteros en vez de decimales a través del internet por rendimiento. Se parece que los valores de amenaza son multiplicados por 207.35 al servidor, pues redondeado.

Si quiere usar el 1 daño = 1 amenaza método todavía; los modificadores de actitud son 0.8 y 2.0735, etc..

|cffffd200Valores de Amenaza (modificadores de actitud aplica a menos que dijera otra cosa):|r
Grito de batalla _________ 78 (divido)
Rajar _______________ daño + 225 (divido)
Grito de orden _____ 80 (divido)
Arremetida de conmoción ______ daño solamente
Escudo de daño ________ daño solamente
Grito desmoralizador ___ 63 (divido)
Devastar ____________ daño + 5% of AP
Esquivar/Parar/Bloquear_____ 1 (en actitud defensiva solamente con Actitud defensiva mejorada)
Golpe heroico ________ daño + 259
Tira heroico _________ 1.50 x daño
Gana de ira ____________ 5 (sin modificador de actitud)
Desgarrar _________________ daño solamente
Revancha ______________ daño + 121
Azote de escudo __________ 36
Embate con escudo __________ daño + 770
Onda de choque ____________ daño solamente
Embate _________________ daño + 140
Reflejo de hechizos ________ daño solamente
Aggro Social _________ 0
Hender armadura ________ 345 + 5%AP
Atronar _________ 1.85 x daño
Vigilancia ____________ 10% de la amenaza del blanco (sin modificador de actitud)

No gana amenaza por reflejar hechizos apuntado a su aliados con Reflejo de hechizos mejorado. Cuándo refleja un hechizo por un aliado, el aliado gana la amenaza por el daño del hechizo.
]]

