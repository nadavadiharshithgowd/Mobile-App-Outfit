import type { TryOnStatusUpdate } from '@/types/tryon.types';

const WS_BASE_URL = import.meta.env.VITE_WS_BASE_URL || 'ws://localhost:8000';

export class TryOnWebSocket {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000;
  private everOpened = false;

  connect(
    tryonId: string,
    onMessage: (data: TryOnStatusUpdate) => void,
    onError?: (error: Event) => void
  ): WebSocket {
    const token = localStorage.getItem('access_token');
    const wsUrl = `${WS_BASE_URL}/ws/tryon/${tryonId}/status/?token=${token}`;

    this.ws = new WebSocket(wsUrl);

    this.ws.onopen = () => {
      this.everOpened = true;
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data) as TryOnStatusUpdate;
        onMessage(data);
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    };

    this.ws.onerror = () => {
      // Suppress noisy error logs — onclose handles the fallback
    };

    this.ws.onclose = (event) => {
      // Server rejected the upgrade (404/WSGI) — never actually connected.
      // Fall back to polling immediately without reconnect spam.
      if (!this.everOpened) {
        if (onError) onError(new Event('ws_unavailable'));
        return;
      }

      // Lost an established connection — attempt reconnect with backoff.
      if (event.code !== 1000 && this.reconnectAttempts < this.maxReconnectAttempts) {
        this.reconnectAttempts++;
        setTimeout(() => {
          this.connect(tryonId, onMessage, onError);
        }, this.reconnectDelay * this.reconnectAttempts);
      } else if (onError) {
        onError(new Event('ws_closed'));
      }
    };

    return this.ws;
  }
  
  disconnect() {
    if (this.ws) {
      this.ws.close(1000, 'Client disconnect');
      this.ws = null;
    }
  }
  
  isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN;
  }
}
