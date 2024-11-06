import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { APP_INITIALIZER, NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutingModule } from '@app/modules/app-routing.module';
import { AppMaterialModule } from '@app/modules/material.module';

import { AppComponent } from '@app/pages/app/app.component';
import { ConfigPageComponent } from '@app/pages/config-page/config-page.component';
import { CreationPageComponent } from '@app/pages/creation-page/creation-page.component';
import { GamePageComponent } from '@app/pages/game-page/game-page.component';
import { GameSelectionPageComponent } from '@app/pages/game-selection-page/game-selection-page.component';
import { MainPageComponent } from '@app/pages/main-page/main-page.component';

import { MatCheckboxModule } from '@angular/material/checkbox';
import { ModalConfirmationComponent } from '@app/components/modal-confirmation/modal-confirmation.component';
import { ProfileCardComponent } from '@app/components/profile-card/profile-card.component';
import { ProfilePageComponent } from '@app/pages/profile-page/profile-page.component';
import { ConfigParametersComponent } from '@components/config-parameters/config-parameters.component';
import { CreationCanvasesComponent } from '@components/creation-canvases/creation-canvases.component';
import { CreationToolbarComponent } from '@components/creation-toolbar/creation-toolbar.component';
import { GameSelectionCarouselComponent } from '@components/game-selection-carousel/game-selection-carousel.component';
import { HistoryComponent } from '@components/history/history.component';
import { InfoCardComponent } from '@components/info-card/info-card.component';
import { ModalDifferenceComponent } from '@components/modal-difference/modal-difference.component';
import { ModalEndgameComponent } from '@components/modal-endgame/modal-endgame.component';
import { ModalGameChooserComponent } from '@components/modal-game-chooser/modal-game-chooser.component';
import { ModalReplayComponent } from '@components/modal-replay/modal-replay.component';
import { PlayAreaComponent } from '@components/play-area/play-area.component';
import { PlayerDiscriminatorComponent } from '@components/player-discriminator/player-discriminator.component';
import { SidebarComponent } from '@components/sidebar/sidebar.component';
import { TimerComponent } from '@components/timer/timer.component';
import { TitleBarComponent } from '@components/title-bar/title-bar.component';
import { WaitingSpinnerComponent } from '@components/waiting-spinner/waiting-spinner.component';
import { NgxEchartsModule } from 'ngx-echarts';
import { AuthInterceptor } from './auth/auth.interceptor';
import { AccountHistoryComponent } from './components/account-history/account-history.component';
import { ChatCreationDialogComponent } from './components/chat-creation-dialog/chat-creation-dialog.component';
import { ChatJoinDialogComponent } from './components/chat-join-dialog/chat-join-dialog.component';
import { ChatComponent } from './components/chat/chat.component';
import { ColorInputComponent } from './components/color-input/color-input.component';
import { FriendListComponent } from './components/friend-list/friend-list.component';
import { FriendRequestsComponent } from './components/friend-requests/friend-requests.component';
import { HintCanvasComponent } from './components/hint-canvas/hint-canvas.component';
import { LobbyCardComponent } from './components/lobby-card/lobby-card.component';
import { LocaleSwitcherComponent } from './components/locale-switcher/locale-switcher.component';
import { MarketConfirmationDialogComponent } from './components/market-confirmation-dialog/market-confirmation-dialog.component';
import { ModalConfigurationPasswordComponent } from './components/modal-configuration-password/modal-configuration-password.component';
import { ModalReplayChooserComponent } from './components/modal-replay-chooser/modal-replay-chooser.component';
import { ObserverDrawHintComponent } from './components/observer-draw-hint/observer-draw-hint.component';
import { PopoutWindowModule } from './components/popout-window/popout-window.module';
import { ProfileGameHistoryComponent } from './components/profile-game-history/profile-game-history.component';
import { ReplayListComponent } from './components/replay-list/replay-list.component';
import { SettingsCardComponent } from './components/settings-card/settings-card.component';
import { StatisticCardComponent } from './components/statistic-card/statistic-card.component';
import { UserFriendsModalComponent } from './components/user-friends-modal/user-friends-modal.component';
import { UserItemComponent } from './components/user-item/user-item.component';
import { UserListItemComponent } from './components/user-list-item/user-list-item.component';
import { UserSearchModalComponent } from './components/user-search-modal/user-search-modal.component';
import { JoinGamePageComponent } from './pages/join-game-page/join-game-page.component';
import { MarketPageComponent } from './pages/market-page/market-page.component';
import { ThemeService } from './services/theme.service';

/**
 * Main module that is used in main.ts.
 * All automatically generated components will appear in this module.
 * Please do not move this module in the module folder.
 * Otherwise Angular Cli will not know in which module to put new component
 */
@NgModule({
    declarations: [
        MarketConfirmationDialogComponent,
        ModalReplayChooserComponent,
        AppComponent,
        ChatCreationDialogComponent,
        ChatJoinDialogComponent,
        ChatComponent,
        ModalGameChooserComponent,
        GamePageComponent,
        MainPageComponent,
        PlayAreaComponent,
        SidebarComponent,
        CreationCanvasesComponent,
        CreationPageComponent,
        GameSelectionPageComponent,
        JoinGamePageComponent,
        LobbyCardComponent,
        GamePageComponent,
        InfoCardComponent,
        MainPageComponent,
        PlayAreaComponent,
        SidebarComponent,
        TitleBarComponent,
        GameSelectionCarouselComponent,
        ConfigPageComponent,
        TimerComponent,
        ModalDifferenceComponent,
        ModalEndgameComponent,
        CreationToolbarComponent,
        PlayerDiscriminatorComponent,
        ModalReplayComponent,
        HistoryComponent,
        WaitingSpinnerComponent,
        ModalConfirmationComponent,
        ConfigParametersComponent,
        AccountHistoryComponent,
        ProfileGameHistoryComponent,
        ProfilePageComponent,
        ProfileCardComponent,
        StatisticCardComponent,
        FriendListComponent,
        UserSearchModalComponent,
        UserFriendsModalComponent,
        UserListItemComponent,
        FriendRequestsComponent,
        MarketPageComponent,
        HintCanvasComponent,
        ObserverDrawHintComponent,
        ReplayListComponent,
        ModalConfigurationPasswordComponent,
        ColorInputComponent,
        UserItemComponent,
        SettingsCardComponent,
    ],
    imports: [
        ReactiveFormsModule,
        MatCheckboxModule,
        AppMaterialModule,
        AppRoutingModule,
        BrowserAnimationsModule,
        BrowserModule,
        FormsModule,
        PopoutWindowModule,
        HttpClientModule,
        NgxEchartsModule.forRoot({
            // eslint-disable-next-line @typescript-eslint/promise-function-async
            echarts: () => import('echarts'), // or use 'echarts/core' if you know what you are doing
        }),
        LocaleSwitcherComponent,
    ],
    providers: [
        {
            provide: HTTP_INTERCEPTORS,
            useClass: AuthInterceptor,
            multi: true,
        },
        {
            provide: ThemeService,
        },
        {
            provide: APP_INITIALIZER,
            useFactory: (themeService: ThemeService) => () => {
                themeService.initTheme();
            },
            deps: [ThemeService],
            multi: true,
        },
    ],
    bootstrap: [AppComponent],
})
export class AppModule {}
