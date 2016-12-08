@Tags(const ['codegen'])
@TestOn('browser')
library angular2.test.common.styling.shim_test;

import 'dart:html';
import 'package:angular2/angular2.dart';
import 'package:angular2/testing_experimental.dart';
import 'package:test/test.dart';

void main() {
  group('host styling', () {
    tearDown(disposeAnyRunningTest);

    test('should apply host style', () async {
      var testBed = new NgTestBed<HostStyleTestComponent>();
      NgTestFixture<HostStyleTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.element;
      expectColor(elm, '#40FF7F');
    });

    test('should apply host style to nested components', () async {
      var testBed = new NgTestBed<HostStyleContainerComponent>();
      NgTestFixture<HostStyleContainerComponent> testFixture =
          await testBed.create();
      Element host1 = testFixture.element.querySelector('host-test');
      Element host2 = testFixture.element.querySelector('host-test2');
      expectColor(host1, '#40FF7F');
      expectColor(host2, '#FF0000');
    });

    test('should apply style to element under host', () async {
      var testBed = new NgTestBed<HostElementSelectorTestComponent>();
      NgTestFixture<HostElementSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.element.querySelector('div');
      expectColor(elm, '#FF0000');

      elm = testFixture.element.querySelector('section');
      expectColor(elm, '#0000FF');
    });

    test('should apply style using element selector', () async {
      var testBed = new NgTestBed<ElementSelectorTestComponent>();
      NgTestFixture<ElementSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.element.querySelector('div');
      expectColor(elm, '#A0B0C0');

      elm = testFixture.element.querySelector('section');
      expectColor(elm, '#C0B0A0');
    });

    test("should apply style using element selector in nested components",
        () async {
      var testBed = new NgTestBed<ContentSelectorTestComponent>();
      NgTestFixture<ContentSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.element.querySelector('#section1');
      expectColor(elm, '#008000');

      elm = testFixture.element.querySelector('#section2');
      expectColor(elm, '#FF0000');

      elm = testFixture.element.querySelector('#section3');
      expectColor(elm, '#008000');
    });

    test('element selector style should not leak into children', () async {
      var testBed = new NgTestBed<ContentSelectorTestComponent>();
      NgTestFixture<ContentSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.element.querySelector('#sectionA');
      expectColor(elm, '#000000');
    });
  });
}

@Component(
    selector: 'host-test',
    template: '<div id="item1">Test1</div><ng-content></ng-content>',
    styles: const [':host { color: rgb(64, 255, 127); }'])
class HostStyleTestComponent {}

@Component(
    selector: 'host-test2',
    template: '<div id="item1">Test2</div>',
    styles: const [':host { color: red; }'])
class HostStyle2TestComponent {}

/// Nests one host inside other.
@Component(
    selector: 'host-container',
    template: '<host-test><host-test2></host-test2></host-test>',
    styles: const [':host { color: rgb(0, 0, 0); }'],
    directives: const [HostStyleTestComponent, HostStyle2TestComponent])
class HostStyleContainerComponent {}

@Component(
    selector: 'host-element-selector-test',
    template: '<div id="item1">Hello</div>'
        '<section class="disabled" id="item2">Hello</section>',
    styles: const [
      ':host > div { color: red; }'
          ':host section { color: blue; }'
    ])
class HostElementSelectorTestComponent {}

@Component(
    selector: 'element-selector-test',
    template: '<div id="item1">Hello</div>'
        '<section class="disabled" id="item2">Hello</section>',
    styles: const [
      'div { color: #A0B0C0; }'
          'section { color: #C0B0A0; }'
    ])
class ElementSelectorTestComponent {}

@Component(
    selector: 'content-selector-test',
    template: '<section class="sec1" id="section1">Section1</section>'
        '<section class="sec2 activated" id="section2">Section2</section>'
        '<section class="sec3" id="section3">Section3</section>'
        '<content-selector-test-child></content-selector-test-child>',
    styles: const [
      'section { color: green; }'
          'section.activated { color: red; }'
          'section.disabled { color: blue; }'
    ],
    directives: const [
      ContentSelectorChildComponent
    ])
class ContentSelectorTestComponent {}

@Component(
    selector: 'content-selector-test-child',
    template: '<section class="secA" id="sectionA">SectionA</section>'
        '<content-selector-test-child></content-selector-test-child>')
class ContentSelectorChildComponent {}

void expectColor(Element element, String color) {
  String elementColor = element.getComputedStyle().color;
  elementColor = colorToHex(elementColor);
  expect(elementColor, color);
}

void expectBackgroundColor(Element element, String color) {
  String elementColor = element.getComputedStyle().backgroundColor;
  elementColor = colorToHex(elementColor);
  expect(elementColor, color);
}

// Converts rgb() rgba() to hex color value.
String colorToHex(String value) {
  value = value.trim();
  if (value.startsWith('rgb')) {
    int parenStartIndex = value.indexOf('(');
    int parenEndIndex = value.lastIndexOf(')');
    if (parenStartIndex != -1 && parenEndIndex != -1) {
      List<String> components =
          value.substring(parenStartIndex + 1, parenEndIndex).split(',');
      StringBuffer sb = new StringBuffer();
      for (int i = 0, len = components.length; i < len && i < 3; i++) {
        String hex = int.parse(components[i]).toRadixString(16);
        if (hex.length < 2) sb.write('0');
        sb.write(hex);
      }
      if (components.length == 4) {
        // Parse alpha.
        String hex =
            (double.parse(components[3]) * 256).toInt().toRadixString(16);
        if (hex.length < 2) hex = '0$hex';
        return '#$hex$sb}';
      }
      return '#${sb.toString().toUpperCase()}';
    }
  }
  return value;
}