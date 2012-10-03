/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/
CKEDITOR.editorConfig = function( config ) {
    // Define changes to default configuration here. For example
    config.language = 'ru';
    config.uiColor = '#BBD9EE'; //цвет рамки
    config.toolbar = 'Basic'; //функциональность редактора, Basic-минимум, Full-максимум
    config.toolbar_Basic = [
        ['Source','-','ShowBlocks','-','PasteText','PasteFromWord','-','Undo','Redo'],
        ['NumberedList','BulletedList','-','Outdent','Indent','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl'],'/',
        ['Image','Flash','HorizontalRule','Table','SpecialChar'],
        ['Bold','Italic','Underline','Strike','Subscript','Superscript','RemoveFormat'],
        ['Link','Unlink'],
        { name: 'colors', items : [ 'TextColor','BGColor' ] },'/',
        { name: 'styles', items : [ /*'Styles',*/'Format','Font','FontSize' ] },
    ];
    config.width = 590; //ширина окна редактора
};