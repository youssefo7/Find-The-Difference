/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/member-ordering */
/* eslint-disable @typescript-eslint/no-magic-numbers */
/* eslint-disable-next-line @typescript-eslint/member-ordering */

import { ChangeDetectorRef, Component, ElementRef, EventEmitter, HostListener, Input, OnDestroy, Output, Renderer2, ViewChild } from '@angular/core';

@Component({
    selector: 'app-popout-window',
    templateUrl: './popout-window.component.html',
    styleUrls: ['./popout-window.component.scss'],
})
export class PopoutWindowComponent implements OnDestroy {
    @Input() windowTitle: string;
    @Input() whiteIcon: boolean;
    @Input() wrapperRetainSizeOnPopout: boolean;
    @Output() closed = new EventEmitter<boolean>();
    @Output() popoutOpened = new EventEmitter<void>();
    @Output() popoutClosed = new EventEmitter<void>();

    @ViewChild('innerWrapper') private innerWrapper: ElementRef;
    @ViewChild('popoutWrapper') private popoutWrapper: ElementRef;

    innerWrapperStyle: Record<string, unknown> | null;
    private popoutWindow: any;
    private observer: MutationObserver;

    constructor(
        private renderer2: Renderer2,
        private cd: ChangeDetectorRef,
    ) {}

    @HostListener('window:beforeunload')
    beforeunloadHandler(): void {
        this.close();
    }

    get isPoppedOut() {
        return !!this.popoutWindow;
    }

    ngOnDestroy(): void {
        this.observer?.disconnect();
        this.close();
    }

    popIn(): void {
        this.renderer2.appendChild(this.popoutWrapper.nativeElement, this.innerWrapper.nativeElement);
        this.close();
        this.cd.detectChanges();
    }

    popOut(event?: MouseEvent): void {
        if (!this.popoutWindow) {
            this.createPopoutWindow(event);
            this.cloneStylesToPopoutWindow();
            this.observeFutureStyleChanges();

            this.renderer2.appendChild(this.popoutWindow.document.body, this.innerWrapper.nativeElement);

            this.popoutWindow.addEventListener('unload', () => this.popIn());
            this.popoutOpened.emit();
            this.cd.detectChanges();
        } else {
            this.popoutWindow.focus();
        }
    }

    private createPopoutWindow(mouseEvent?: MouseEvent) {
        const elmRect = this.innerWrapper.nativeElement.getBoundingClientRect();
        this.innerWrapperStyle = this.wrapperRetainSizeOnPopout ? { width: elmRect.width + 'px', height: elmRect.height + 'px' } : null;

        const [winLeft, winTop] = this.getWindowPositioning(elmRect, mouseEvent);

        this.popoutWindow = window.open(
            '',
            `popoutWindow${Date.now()}`,
            `width=${elmRect.width},
        height=${elmRect.height + 1},
        left=${winLeft},
        top=${winTop}`,
        ) as Window;

        this.popoutWindow.document.title = this.windowTitle || window.document.title;
        this.popoutWindow.document.body.style.margin = '0';
    }

    private getWindowPositioning(elmRect: DOMRect, mouseEvent?: MouseEvent) {
        const navHeight = window.outerHeight - window.innerHeight;
        const navWidth = (window.outerWidth - window.innerWidth) / 2;

        let winTop = window.screenY + navHeight + elmRect.top - 60;
        let winLeft = window.screenX + navWidth + elmRect.left;

        // Position window titleBar under mouse
        if (mouseEvent) {
            winTop = mouseEvent.clientY + navHeight - 7;
            winLeft += 120;
        }

        return [winLeft, winTop];
    }

    private close(): void {
        if (this.popoutWindow) {
            this.popoutWindow.close();
            this.popoutWindow = null;
            this.innerWrapperStyle = null;
            this.popoutClosed.emit();
            this.closed.next(true);
        }
    }

    private cloneStylesToPopoutWindow() {
        const fallbackStyles = `
        :root {
            --primary-500: #c4f9ff; 
            --accent-500: #ffe085;
        }
    `;
        const styleElement = this.popoutWindow.document.createElement('style');
        styleElement.textContent = fallbackStyles;
        this.popoutWindow.document.head.appendChild(styleElement);
        if (window.navigator.userAgent.indexOf('Firefox') === -1) {
            document.fonts.forEach((node) => {
                (this.popoutWindow.document as any).fonts.add(node);
            });
        }

        document.head.querySelectorAll('link[rel="stylesheet"]').forEach((node) => {
            this.popoutWindow.document.head.insertAdjacentHTML(
                'beforeend',
                `<link rel="stylesheet" type="${(node as HTMLLinkElement).type}" href="${(node as HTMLLinkElement).href}">`,
            );
        });

        document.head.querySelectorAll('style').forEach((node) => {
            this.popoutWindow.document.head.appendChild(node.cloneNode(true));
        });
    }

    private observeFutureStyleChanges() {
        const headEle = document.querySelector('head');

        this.observer?.disconnect();
        this.observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeName === 'STYLE') {
                        this.popoutWindow.document.head.appendChild(node.cloneNode(true));
                    }
                });
            });
        });

        if (!headEle) return;

        this.observer.observe(headEle, { childList: true });
    }
}
