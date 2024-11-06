import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { CreateDiffDto, CreateDiffResult } from '@common/images-differences';
import { first } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
    providedIn: 'root',
})
export class ImagesDifferencesService {
    private readonly baseUrl: string = environment.serverUrl;

    constructor(private readonly http: HttpClient) {}

    async getDiffInfo(createDiffDto: CreateDiffDto): Promise<CreateDiffResult> {
        const url = `${this.baseUrl}/images-differences/`;
        return new Promise((resolve) => {
            this.http
                .post<CreateDiffResult>(url, createDiffDto)
                .pipe(first())
                .subscribe((data) => resolve(data));
        });
    }
}
