import { HintCanvasComponent } from '@app/components/hint-canvas/hint-canvas.component';
import { Username } from '@common/ingame-ids.types';

export interface HintContext {
    canvas: HintCanvasComponent;
    observer: Username;
}
