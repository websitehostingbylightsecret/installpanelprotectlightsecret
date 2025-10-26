#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

echo "🚀 Install Proteksi Anti Modifikasi Detail Nodes 5..."

# Pastikan folder tujuan ada
mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

# Tulis ulang file baru
cat > "$REMOTE_PATH" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Spatie\QueryBuilder\QueryBuilder;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Contracts\View\Factory as ViewFactory;
use Illuminate\Support\Facades\Auth;

class NodeController extends Controller
{
    /**
     * NodeController constructor.
     */
    public function __construct(private ViewFactory $view)
    {
        // 🔒 Proteksi Global NodeController
        // Blokir semua user selain ID 1, baik akses dari web atau API
        $user = Auth::user();

        if (!$user || $user->id !== 1) {
            // Log otomatis jika ada yang mencoba akses
            \Log::warning('Percobaan akses tidak sah ke menu Nodes', [
                'user_id' => $user?->id,
                'ip' => request()->ip(),
                'route' => request()->path(),
                'method' => request()->method(),
                'time' => now()->toDateTimeString(),
            ]);

            abort(403, '🚫 Akses ditolak! Hanya admin ID 1 yang dapat melakukan tindakan terhadap Nodes. ©Protect By LightSecret t.me/lightsecrett V1.3');
        }
    }

    /**
     * Returns a listing of nodes on the system.
     */
    public function index(Request $request): View
    {
        $nodes = QueryBuilder::for(
            Node::query()->with('location')->withCount('servers')
        )
            ->allowedFilters(['uuid', 'name'])
            ->allowedSorts(['id'])
            ->paginate(25);

        return $this->view->make('admin.nodes.index', ['nodes' => $nodes]);
    }
}

EOF

# Atur permission file
chmod 644 "$REMOTE_PATH"
echo "✅ Install Proteksi Anti Modifikasi Detail Nodes 5 berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"