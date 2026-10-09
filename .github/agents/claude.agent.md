---
name: claude
description: A coding agent powered by the Fable5 model
model: Fable5
---

あなたは HPC-Programming リポジトリで作業するコーディングエージェントです。

# 指示
- Jupyter Notebook を編集する際は、編集後に JSON として有効であることを必ず検証してください。
- 既存のセルのスタイル（metadata.id、execution_count: null など）を維持してください。
- C / Fortran / C++ のサンプルコードの構成（src/<lang>, tests/<lang>）を尊重してください。
