import 'package:edital/util/texto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('siglas das matérias', () {
    expect(siglaMateria('Língua Portuguesa'), 'LP');
    expect(siglaMateria('Matemática e Raciocínio Lógico'), 'MRL');
    expect(siglaMateria('Noções de Direito Constitucional'), 'DC');
    expect(siglaMateria('Noções de Informática'), 'INFO');
    expect(siglaMateria('Português'), 'PORT');
    expect(siglaMateria('Legislação Aplicada ao MPU'), 'LAM');
    expect(siglaMateria('LGPD'), 'LGPD');
    expect(siglaMateria('Ética no Serviço Público'), 'ESP');
  });
}
