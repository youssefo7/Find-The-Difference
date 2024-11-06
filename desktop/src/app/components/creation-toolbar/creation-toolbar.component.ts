import { Component, EventEmitter, Input, Output, ViewEncapsulation } from '@angular/core';
import { BMP_BIT_DEPTH } from '@app/constants/game-creation';
import { DrawingTools } from '@app/interfaces/drawing-tools';
import { ImageService } from '@app/services/image.service';
import { IMAGE_HEIGHT, IMAGE_WIDTH, POSSIBLE_RADIUS_VALUES } from '@common/constants';
import { ImageClicked } from '@common/game-template';
import { DrawService } from '@services/draw.service';

@Component({
    selector: 'app-creation-toolbar',
    templateUrl: './creation-toolbar.component.html',
    styleUrls: ['./creation-toolbar.component.scss'],
    encapsulation: ViewEncapsulation.None,
})
export class CreationToolbarComponent {
    @Output() fileSelected = new EventEmitter<Event>();
    @Output() refreshDiff = new EventEmitter<void>();
    @Input() modalOpen: boolean;

    protected imageWidth = IMAGE_WIDTH;
    protected imageHeight = IMAGE_HEIGHT;
    protected bmpBitDepth = BMP_BIT_DEPTH;
    protected possibleRadiusValues = POSSIBLE_RADIUS_VALUES;

    protected drawingTools = DrawingTools;
    protected imageClicked = ImageClicked;

    constructor(
        public drawService: DrawService,
        public imageService: ImageService,
    ) {}

    get sprayPerSecondSliderEnabled(): boolean {
        return this.drawService.selectedTool === DrawingTools.Spray;
    }

    get lineWidthSliderEnabled(): boolean {
        return (
            this.drawService.selectedTool === DrawingTools.Pen ||
            this.drawService.selectedTool === DrawingTools.Eraser ||
            this.drawService.selectedTool === DrawingTools.Spray
        );
    }
}
