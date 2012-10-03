myBbcodeSettings = {
  nameSpace: "bbcode",
  markupSet: [
      {name:'Жирный', openWith:'[b]', closeWith:'[/b]'},
      {name:'Курсив', openWith:'[i]', closeWith:'[/i]'},
      {name:'Подчеркнутый', openWith:'[u]', closeWith:'[/u]'},
      {name:'Зачеркнутый', openWith:'[s]', closeWith:'[/s]'},
      {separator:'---------------' },
      {name:'Выровнять влево', openWith:'[left]', closeWith:'[/left]'},
      {name:'Выровнять по центру', openWith:'[center]', closeWith:'[/center]'},
      {name:'Выровнять вправо', openWith:'[right]', closeWith:'[/right]'},
      {separator:'---------------' },
      {name:'Размер шрифта', openWith:'[size=[![Введите размер шрифта]!]]', closeWith:'[/size]',
      dropMenu :[
          {name:'Маленький', openWith:'[size=8]', closeWith:'[/size]' },
          {name:'Нормальный', openWith:'[size=11]', closeWith:'[/size]' },
          {name:'Большой', openWith:'[size=18]', closeWith:'[/size]' }
      ]},
      {name:'Цвет текста', dropMenu: [
          {name:'Желтый', openWith:'[color=yellow]', closeWith:'[/color]', className:"col1-1" },
          {name:'Ораньжевый', openWith:'[color=orange]', closeWith:'[/color]', className:"col1-2" },
          {name:'Красный', openWith:'[color=red]', closeWith:'[/color]', className:"col1-3" },
          {name:'Синий', openWith:'[color=blue]', closeWith:'[/color]', className:"col2-1" },
          {name:'Пурпурный', openWith:'[color=purple]', closeWith:'[/color]', className:"col2-2" },
          {name:'Зеленый', openWith:'[color=green]', closeWith:'[/color]', className:"col2-3" },
          {name:'Белый', openWith:'[color=white]', closeWith:'[/color]', className:"col3-1" },
          {name:'Серый', openWith:'[color=gray]', closeWith:'[/color]', className:"col3-2" },
          {name:'Черный', openWith:'[color=black]', closeWith:'[/color]', className:"col3-3" }
      ]},
      {separator:'---------------' },
      {name:'Вставить ссылку', openWith:'[url=[![Введите URL ссылки]!]]', closeWith:'[/url]', placeHolder:'ссылка'},
      {name:'Вставить изображение', replaceWith:'[img][![Введите URL картинки]!][/img]'}, 
      {name:'Вставить видео',className:"video", replaceWith:'[video][![Введите URL видео. Пример - http://www.youtube.com/watch?v=RtFiF3lD2Gw http://planet.setka.zp.ua/users_videos/video/3902_8508]!][/video]'},
      {separator:'---------------' },
      {name:'Цитата', openWith:'[quote]', closeWith:'[/quote]'},
      {name:'Убрать теги', className:"clean", replaceWith:function(markitup) { return markitup.selection.replace(/\[(.*?)\]/g, "") } },
   ]
}