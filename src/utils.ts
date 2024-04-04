import { HttpService } from "@rbxts/services";

export function toString(val: unknown): string {
    return HttpService.JSONEncode(val);
}
