import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { PopoutWindowComponent } from './popout-window.component';

@NgModule({
    declarations: [PopoutWindowComponent],
    imports: [CommonModule, MatIconModule],
    exports: [PopoutWindowComponent],
})
export class PopoutWindowModule {}
