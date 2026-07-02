#!/bin/bash
# ------------------------------------------------------------------
# Yeni bir feature için standart klasör yapısını ve boilerplate
# kodları otomatik oluşturur.
#
# Kullanım:
#   ./scripts/create_feature.sh <feature_adi_snake_case>
#
# Örnek:
#   ./scripts/create_feature.sh zikir
#   ./scripts/create_feature.sh sesli_kuran
#
# NOT: Bu script proje kök dizininden (pubspec.yaml'ın olduğu yerden)
# çalıştırılmalı.
# ------------------------------------------------------------------

set -e

if [ -z "$1" ]; then
  echo "Kullanım: ./scripts/create_feature.sh <feature_adi_snake_case>"
  echo "Örnek:    ./scripts/create_feature.sh zikir"
  exit 1
fi

if [ ! -f "pubspec.yaml" ]; then
  echo "HATA: Bu script proje kök dizininden calistirilmali (pubspec.yaml bulunamadi)."
  exit 1
fi

FEATURE_NAME=$1

# snake_case -> PascalCase (örn: sesli_kuran -> SesliKuran)
PASCAL_NAME=$(echo "$FEATURE_NAME" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' OFS='')

BASE_DIR="lib/features/$FEATURE_NAME/presentation"

if [ -d "$BASE_DIR" ]; then
  echo "HATA: '$BASE_DIR' zaten mevcut. Farkli bir isim dene ya da mevcut klasoru sil."
  exit 1
fi

mkdir -p "$BASE_DIR/bloc"
mkdir -p "$BASE_DIR/event"
mkdir -p "$BASE_DIR/state"
mkdir -p "$BASE_DIR/pages"
mkdir -p "$BASE_DIR/widgets"

# ---------------- event ----------------
cat > "$BASE_DIR/event/${FEATURE_NAME}_event.dart" <<EOF
import 'package:equatable/equatable.dart';

sealed class ${PASCAL_NAME}Event extends Equatable {
  const ${PASCAL_NAME}Event();

  @override
  List<Object?> get props => [];
}

// TODO: Gercek event'leri buraya ekle. Ornek:
// class ${PASCAL_NAME}Started extends ${PASCAL_NAME}Event {
//   const ${PASCAL_NAME}Started();
// }
EOF

# ---------------- state ----------------
cat > "$BASE_DIR/state/${FEATURE_NAME}_state.dart" <<EOF
import 'package:equatable/equatable.dart';

enum ${PASCAL_NAME}Status { initial, loading, success, failure }

class ${PASCAL_NAME}State extends Equatable {
  const ${PASCAL_NAME}State({
    this.status = ${PASCAL_NAME}Status.initial,
  });

  final ${PASCAL_NAME}Status status;

  ${PASCAL_NAME}State copyWith({
    ${PASCAL_NAME}Status? status,
  }) {
    return ${PASCAL_NAME}State(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
EOF

# ---------------- bloc ----------------
cat > "$BASE_DIR/bloc/${FEATURE_NAME}_bloc.dart" <<EOF
import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/${FEATURE_NAME}_event.dart';
import '../state/${FEATURE_NAME}_state.dart';

class ${PASCAL_NAME}Bloc extends Bloc<${PASCAL_NAME}Event, ${PASCAL_NAME}State> {
  ${PASCAL_NAME}Bloc() : super(const ${PASCAL_NAME}State()) {
    // TODO: Event handler'lari buraya ekle. Ornek:
    // on<${PASCAL_NAME}Started>(_onStarted);
  }
}
EOF

# ---------------- page ----------------
cat > "$BASE_DIR/pages/${FEATURE_NAME}_page.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/${FEATURE_NAME}_bloc.dart';
import '../state/${FEATURE_NAME}_state.dart';

class ${PASCAL_NAME}Page extends StatelessWidget {
  const ${PASCAL_NAME}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ${PASCAL_NAME}Bloc(),
      child: Scaffold(
        body: BlocBuilder<${PASCAL_NAME}Bloc, ${PASCAL_NAME}State>(
          builder: (context, state) {
            // TODO: UI'yi buraya ekle.
            return const Center(child: Text('${PASCAL_NAME}Page'));
          },
        ),
      ),
    );
  }
}
EOF

# widgets/ klasoru bos kaliyor, ilk widget eklendiginde doldurulacak.
touch "$BASE_DIR/widgets/.gitkeep"

echo ""
echo "'$FEATURE_NAME' feature'i olusturuldu -> $BASE_DIR"
echo ""
find "$BASE_DIR" -type f | sort
