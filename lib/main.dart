import 'package:flutter/material.dart';

void main() {
  runApp(const MiAppCasa());
}

class MiAppCasa extends StatelessWidget {
  const MiAppCasa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RegistroComprasPantalla(),
    );
  }
}

class ProductoCompra {
  final String nombre;
  final String lugar;
  final int cantidad;
  final double precioUnitario;

  ProductoCompra({
    required this.nombre,
    required this.lugar,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;
}

class RegistroComprasPantalla extends StatefulWidget {
  const RegistroComprasPantalla({super.key});

  @override
  State<RegistroComprasPantalla> createState() => _RegistroComprasPantallaState();
}

class _RegistroComprasPantallaState extends State<RegistroComprasPantalla> {
  final _lugarController = TextEditingController();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();
  final _descuentoController = TextEditingController();

  final List<ProductoCompra> _productos = [];
  bool _descuentoEnPorcentaje = true; // Controla si el descuento es % o $

  void _agregarProducto() {
    final lugar = _lugarController.text.trim();
    final nombre = _nombreController.text.trim();
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;
    final precio = double.tryParse(_precioController.text.trim().replaceAll(',', '.')) ?? 0.0;

    if (lugar.isEmpty || nombre.isEmpty || cantidad <= 0 || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos del producto.')),
      );
      return;
    }

    setState(() {
      _productos.add(ProductoCompra(
        nombre: nombre,
        lugar: lugar,
        cantidad: cantidad,
        precioUnitario: precio,
      ));
      _nombreController.clear();
      _cantidadController.clear();
      _precioController.clear();
    });
  }

  void _eliminarProducto(int index) {
    setState(() {
      _productos.removeAt(index);
    });
  }

  double get _subtotalGeneral {
    return _productos.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get _valorDescuento {
    return double.tryParse(_descuentoController.text.trim().replaceAll(',', '.')) ?? 0.0;
  }

  double get _montoDescuentoTotal {
    if (_subtotalGeneral == 0) return 0.0;
    
    double descuentoFinal = 0.0;
    if (_descuentoEnPorcentaje) {
      descuentoFinal = _subtotalGeneral * (_valorDescuento / 100);
    } else {
      descuentoFinal = _valorDescuento;
    }
    
    // Evitamos que el descuento sea mayor a lo que gastamos
    return descuentoFinal > _subtotalGeneral ? _subtotalGeneral : descuentoFinal;
  }

  double get _totalConDescuento {
    return _subtotalGeneral - _montoDescuentoTotal;
  }

  // Distribución equitativa / proporcional del descuento por producto
  double _calcularPrecioFinalUnitario(ProductoCompra prod) {
    if (_subtotalGeneral == 0) return prod.precioUnitario;
    final proporcion = prod.subtotal / _subtotalGeneral;
    final descuentoDelProducto = _montoDescuentoTotal * proporcion;
    final subtotalConDescuento = prod.subtotal - descuentoDelProducto;
    return subtotalConDescuento / prod.cantidad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Compras'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _lugarController,
                  decoration: const InputDecoration(
                    labelText: 'Comercio / Lugar (ej. Supermercado X)',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agregar Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Producto (ej. Fideos 500g)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cantidadController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _precioController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Precio Unit. (\$)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _agregarProducto,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Agregar a la lista'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text('Productos en el Ticket:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            _productos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No hay productos agregados todavía.')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final prod = _productos[index];
                      final precioFinalUnitario = _calcularPrecioFinalUnitario(prod);

                      return Card(
                        child: ListTile(
                          title: Text('${prod.nombre} (x${prod.cantidad})'),
                          subtitle: Text(
                            'Original: \$${prod.precioUnitario.toStringAsFixed(2)} c/u\n'
                            'Con descuento: \$${precioFinalUnitario.toStringAsFixed(2)} c/u',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${(precioFinalUnitario * prod.cantidad).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarProducto(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 12),

            // Sección de Descuento General mejorada
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _descuentoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: _descuentoEnPorcentaje ? 'Descuento (%)' : 'Descuento (\$)',
                              prefixIcon: const Icon(Icons.discount),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: true, label: Text('%')),
                              ButtonSegment(value: false, label: Text('\$')),
                            ],
                            selected: {_descuentoEnPorcentaje},
                            onSelectionChanged: (Set<bool> nuevaSeleccion) {
                              setState(() {
                                _descuentoEnPorcentaje = nuevaSeleccion.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('\$${_subtotalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_descuentoEnPorcentaje ? 'Descuento (${_valorDescuento.toStringAsFixed(1)}%):' : 'Descuento Fijo:'),
                        Text('-\$${_montoDescuentoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL FINAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          '\$${_totalConDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
