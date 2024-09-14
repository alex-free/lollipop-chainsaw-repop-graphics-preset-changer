#include <stdio.h>
#include <shlobj.h>

int main() {
    
    const int modification_offsets[10] = {
        0x46, 0x60, 0x74, 0x94, 0xAC,
        0xC5, 0xDA, 0xEF, 0x104, 0x119
    };

    char game_user_settings_ini_path[MAX_PATH];
    char user_dir[MAX_PATH];

    char graphics_preset;

    // CSIDL_LOCAL_APPDATA 	The file-system directory that serves as a data repository for local, non-roaming applications. A typical path is C:\Users\<username>\AppData\Local. https://learn.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables

    SHGetFolderPath(NULL, CSIDL_PROFILE, NULL, 0, user_dir);

    printf("Lollipop Chainsaw RePOP Graphics Preset Changer %s\nBy Alex Free (c) 2024 3-BSD\n\n", VERSION);

    snprintf(game_user_settings_ini_path, sizeof(game_user_settings_ini_path), "%s\\AppData\\Local\\lollipop\\Saved\\Config\\Windows\\GameUserSettings.ini", user_dir);
    //printf("GameUserSettings.ini full path: %s\n", game_user_settings_ini_path);

    FILE *game_user_settings_ini = fopen(game_user_settings_ini_path,"rb+"); // Open RW binary mode

    if(game_user_settings_ini == NULL)
    {
        printf("Error: Can't find GameUserSettings.ini, which was expected at %s\n", game_user_settings_ini_path);
        return 1;
    }

    for(int i = 0; i < 10; i++)
    {
        //printf("Seek to %d\n", (modification_offsets[i] - 1) );
        fseek(game_user_settings_ini, modification_offsets[i] - 1, SEEK_SET);
        int check_preset = fgetc(game_user_settings_ini); // =
        //printf("Check preset:%c\n", check_preset);
        
        if(check_preset == '=')
        {
            fseek(game_user_settings_ini, modification_offsets[i], SEEK_SET); // Seek to value, 1 or 3.
            check_preset = fgetc(game_user_settings_ini);
            
            if(check_preset == '3')
            {
                graphics_preset = '1';
            } else {
                graphics_preset = '3';
            }

            fseek(game_user_settings_ini, modification_offsets[i], SEEK_SET); // Move back to overwrite previously read value.
            fputc(graphics_preset, game_user_settings_ini);
        } else {
            printf("Error: Can not find = sign for setting number %d. Ensure that GameUserSettings.ini has not been modified by hand with additional added bytes.", i);
            fclose(game_user_settings_ini);
            return 1;
        }      
    }

    if(graphics_preset == '1')
    {
        printf("Graphics set to low.\n");
    } else {
        printf("Graphics set to high.\n");
    }

    fclose(game_user_settings_ini);
    return 0;
}
