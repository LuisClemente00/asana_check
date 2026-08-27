// Archivo: asana_model.dart

import 'package:flutter/material.dart';

class AsanaModel {
  final String id;
  final String title;
  final String sanskrit;
  final String category;
  final String level;
  final IconData icon;

  const AsanaModel({
    required this.id,
    required this.title,
    required this.sanskrit,
    required this.category,
    required this.level,
    required this.icon,
  });

  static const List<AsanaModel> allAsanas = [
    // --- POSTURAS INICIALES ---
    AsanaModel(
      id: 'arbol',
      title: 'El Árbol',
      sanskrit: 'Vrikshasana',
      category: 'Equilibrio',
      level: 'Principiante',
      icon: Icons.park_rounded,
    ),
    AsanaModel(
      id: 'guerrero_2',
      title: 'El Guerrero II',
      sanskrit: 'Virabhadrasana II',
      category: 'Fuerza',
      level: 'Intermedio',
      icon: Icons.accessibility_new_rounded,
    ),
    AsanaModel(
      id: 'plancha',
      title: 'La Plancha',
      sanskrit: 'Phalakasana',
      category: 'Core',
      level: 'Intermedio',
      icon: Icons.horizontal_rule_rounded,
    ),
    AsanaModel(
      id: 'triangulo',
      title: 'El Triángulo',
      sanskrit: 'Trikonasana',
      category: 'Flexibilidad',
      level: 'Principiante',
      icon: Icons.change_history_rounded,
    ),
    AsanaModel(
      id: 'cobra',
      title: 'La Cobra',
      sanskrit: 'Bhujangasana',
      category: 'Espalda',
      level: 'Principiante',
      icon: Icons.waves_rounded,
    ),
    AsanaModel(
      id: 'silla',
      title: 'La Silla',
      sanskrit: 'Utkatasana',
      category: 'Fuerza',
      level: 'Avanzado',
      icon: Icons.chair_rounded,
    ),
    AsanaModel(
      id: 'perro_boca_abajo',
      title: 'Perro Boca Abajo',
      sanskrit: 'Adho Mukha Svanasana',
      category: 'Estiramiento',
      level: 'Principiante',
      icon: Icons.pets_rounded,
    ),
    AsanaModel(
      id: 'guerrero_1',
      title: 'El Guerrero I',
      sanskrit: 'Virabhadrasana I',
      category: 'Fuerza',
      level: 'Principiante',
      icon: Icons.sports_mma_rounded,
    ),
    AsanaModel(
      id: 'media_luna',
      title: 'La Media Luna',
      sanskrit: 'Ardha Chandrasana',
      category: 'Equilibrio',
      level: 'Avanzado',
      icon: Icons.nightlight_round,
    ),
    AsanaModel(
      id: 'puente',
      title: 'El Puente',
      sanskrit: 'Setu Bandhasana',
      category: 'Espalda',
      level: 'Intermedio',
      icon: Icons.shield_outlined,
    ),

    // --- NUEVAS ASANAS AÑADIDAS ---
    AsanaModel(
      id: 'guerrero_3',
      title: 'El Guerrero III',
      sanskrit: 'Virabhadrasana III',
      category: 'Equilibrio',
      level: 'Avanzado',
      icon: Icons.nordic_walking_rounded,
    ),
    AsanaModel(
      id: 'pinza_de_pie',
      title: 'La Pinza de Pie',
      sanskrit: 'Uttanasana',
      category: 'Flexibilidad',
      level: 'Principiante',
      icon: Icons.vertical_align_bottom_rounded,
    ),
    AsanaModel(
      id: 'camello',
      title: 'El Camello',
      sanskrit: 'Ustrasana',
      category: 'Espalda',
      level: 'Intermedio',
      icon: Icons.wb_twilight_rounded,
    ),
    AsanaModel(
      id: 'torsion_sentada',
      title: 'Señor de los Peces',
      sanskrit: 'Ardha Matsyendrasana',
      category: 'Torsión',
      level: 'Intermedio',
      icon: Icons.sync_rounded,
    ),
    AsanaModel(
      id: 'paloma',
      title: 'La Paloma',
      sanskrit: 'Eka Pada Rajakapotasana',
      category: 'Flexibilidad',
      level: 'Avanzado',
      icon: Icons.flutter_dash_rounded,
    ),
    AsanaModel(
      id: 'zapatero',
      title: 'La Mariposa',
      sanskrit: 'Baddha Konasana',
      category: 'Cadera',
      level: 'Principiante',
      icon: Icons.eco_rounded,
    ),
    AsanaModel(
      id: 'guerrero_humilde',
      title: 'Guerrero Humilde',
      sanskrit: 'Baddha Virabhadrasana',
      category: 'Fuerza',
      level: 'Intermedio',
      icon: Icons.nature_people_rounded,
    ),
    AsanaModel(
      id: 'barco',
      title: 'El Barco',
      sanskrit: 'Navasana',
      category: 'Core',
      level: 'Intermedio',
      icon: Icons.sailing_rounded,
    ),
  ];
}