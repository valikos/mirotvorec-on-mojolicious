// ----------------------------------------------------------------------------
// markItUp!
// ----------------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
// BBCode tags example
// http://en.wikipedia.org/wiki/Bbcode
// ----------------------------------------------------------------------------
// Feel free to add more tags
// ----------------------------------------------------------------------------
mySettings = {
    previewParserPath:  '~/bbcode/preview',
    previewAutoRefresh:     false,
    markupSet: [
        {name:'������ �����',className:"b", openWith:'[b]', closeWith:'[/b]'},
        {name:'��������� �����',className:"i", openWith:'[i]', closeWith:'[/i]'},
        {name:'������������ �����',className:"u", openWith:'[u]', closeWith:'[/u]'},
        {name:'������������� �����',className:"s", openWith:'[s]', closeWith:'[/s]'},
        {separator:'---------------' },
        {name:'�������� ��������',className:"img",replaceWith:'[img][![������� url ��������]!][/img]'},
        {name:'�������� ������',className:"url", openWith:'[url=[![������� url ������]!]]', closeWith:'[/url]', placeHolder:'������'},
        {separator:'---------------' },
        {name:'������������', className:'alignments', dropMenu:[
            {name:'�� ������ ����',className:"left", openWith:'[left]', closeWith:'[/left]'},
            {name:'�� ������',className:"center", openWith:'[center]', closeWith:'[/center]'},
            {name:'�� ������� ����',className:"right", openWith:'[right]', closeWith:'[/right]'},
            {name:'�� ������',className:"justify", openWith:'[justify]', closeWith:'[/justify]'}
            ]
        },
        {name:'������ ������',className:"size", openWith:'[size=[![������� ������ ������]!]]', closeWith:'[/size]',
        dropMenu :[
            {name:'�������', openWith:'[size=24]', closeWith:'[/size]' },
            {name:'����������', openWith:'[size=12]', closeWith:'[/size]' },
            {name:'���������', openWith:'[size=8]', closeWith:'[/size]' }
        ]},
        {name:'Colors',className:'colors',openWith:'[color=[![Color]!]]',closeWith:'[/color]',dropMenu: [
                    {name:'Yellow', openWith:'[color=yellow]',  closeWith:'[/color]', className:"col1-1" },
                    {name:'Maroon', openWith:'[color=maroon]',  closeWith:'[/color]', className:"col1-2" },
                    {name:'Red',    openWith:'[color=red]',     closeWith:'[/color]', className:"col1-3" },
                    
                    {name:'Blue',   openWith:'[color=blue]',    closeWith:'[/color]', className:"col2-1" },
                    {name:'Teal', openWith:'[color=teal]',  closeWith:'[/color]', className:"col2-2" },
                    {name:'Green',  openWith:'[color=green]',   closeWith:'[/color]', className:"col2-3" },
                    
                    {name:'White',  openWith:'[color=white]',   closeWith:'[/color]', className:"col3-1" },
                    {name:'Gray',   openWith:'[color=gray]',    closeWith:'[/color]', className:"col3-2" },
                    {name:'Black',  openWith:'[color=black]',   closeWith:'[/color]', className:"col3-3" }
        ]},
        {separator:'---------------' },
        {name:'������������� ������',className:"ol", openWith:'[list]\n', closeWith:'\n[/list]'},
        {name:'������������ ������', className:"ul", openWith:'[list=[![Starting number]!]]\n', closeWith:'\n[/list]'}, 
        {name:'������ ������',className:"li", openWith:'[*] '},
        {name:'�������������� �����',className:"hr", openWith:'[hr]\n'},
        {separator:'---------------' },
        {name:'������',className:"quote", openWith:'[quote]', closeWith:'[/quote]'},
        {name:'���',className:"code", openWith:'[code]', closeWith:'[/code]'},
        {name:'�������',className:"spoiler", openWith:'[spoiler]', closeWith:'[/spoiler]'},
        {name:'�����',className:"video", replaceWith:'[video][![������� url �����. ������ - http://www.youtube.com/watch?v=RtFiF3lD2Gw http://planet.setka.zp.ua/users_videos/video/3902_8508]!][/video]'},
        {name:'��������', className:"preview", call:'preview' },
        {name:'������� ��������', className:"previewc", replaceWith:function() { 
                jQuery(".markItUpPreviewFrame").remove();
                } 
        }
    ]
}