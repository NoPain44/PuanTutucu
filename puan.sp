#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Anıl Can"
#define PLUGIN_VERSION "1.00"

#include < sourcemod >
#include < sdktools >
#include < menu-stocks >
#include < multicolors >

#pragma newdecls required

g_puanmode[ MAXPLAYERS + 1 ];
g_puantarget[ MAXPLAYERS + 1 ];
g_puan[ MAXPLAYERS + 1 ];

public Plugin myinfo = 
{
	name = "Puan",
	author = PLUGIN_AUTHOR,
	description = "Etkinliklerde Oyunculara Puan Vermenizi Saglar",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/cananil44/"
};

public void OnPluginStart()
{
	RegAdminCmd( "sm_puan", PuanMenu, ADMFLAG_KICK );
	RegConsoleCmd( "sm_puanlist", PuanList );
	RegConsoleCmd( "sm_puanim", Puanim );
}
public Action PuanMenu( int client, int args )
{
	g_puanmode[ client ] = -1;
	g_puantarget[ client ] = -1;
	if( IsClientInGame( client ) )
	{
		Menu menu = new Menu( PuanMenu_Handler );
		menu.SetTitle( "Puan Menü" );
		menu.AddItem( "ver", "Puan Ver" );
		menu.AddItem( "al", "Puan Al" );
		menu.Display( client, MENU_TIME_FOREVER ); 
	}
	return Plugin_Handled;
}
public int PuanMenu_Handler( Menu menu, MenuAction action, int param1, int param2 )
{
	if( action == MenuAction_Select )
	{
		char info[ 32 ];
		menu.GetItem( param2, info, sizeof( info ) );
		if( param2 == 0 )
		{
			g_puanmode[ param1 ] = 1;
		}
		else
		{
			g_puanmode[ param1 ] = 0;
		}
		ListPlayer( param1 );
	}
}
public Action ListPlayer( int client )
{
	Menu menu = new Menu( Player_Handler );
	menu.SetTitle( "Oyuncu Secin" );
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame( i ) )
		{
			char liste[ 32 ], name[ MAX_NAME_LENGTH ];
			GetClientName( i, name, sizeof( name ) );
			Format( liste, sizeof( liste ), "%i", i );
			menu.AddItem( liste, name );
			
		}
	}
	menu.Display( client, MENU_TIME_FOREVER );
}
public int Player_Handler( Menu menu, MenuAction action, int param1, int param2 )
{
	if( action == MenuAction_Select )
	{
		char info[ 32 ];
		int target;
		menu.GetItem( param2, info, sizeof( info ) );
		target = StringToInt( info );
		if( target != 0 )
		{
			g_puantarget[ param1 ] = target;
			PuanVerAl( param1 );
		}
	}
}
public Action PuanVerAl( int client )
{
	if( IsClientInGame( client ) )
	{
		Menu menu = new Menu( PuanVerAl_Handler );
		menu.SetTitle( "%N adlı Oyuncudan ( %i Puanı Var )", g_puantarget[ client ], g_puan[ g_puantarget[ client ] ] );
		AddMenuItemFormat( menu, "1", _, "1 Puan %s", g_puanmode[ client ] == 0 ? "al" : "ver" );
		AddMenuItemFormat( menu, "2", _, "2 Puan %s", g_puanmode[ client ] == 0 ? "al" : "ver" );
		AddMenuItemFormat( menu, "3", _, "3 Puan %s", g_puanmode[ client ] == 0 ? "al" : "ver" );
		AddMenuItemFormat( menu, "4", _, "4 Puan %s", g_puanmode[ client ] == 0 ? "al" : "ver" );
		AddMenuItemFormat( menu, "5", _, "5 Puan %s", g_puanmode[ client ] == 0 ? "al" : "ver" );
		menu.Display( client, MENU_TIME_FOREVER ); 
	}
}
public int PuanVerAl_Handler( Menu menu, MenuAction action, int param1, int param2 )
{
	if( action == MenuAction_Select )
	{
		char info[ 32 ];
		menu.GetItem( param2, info, sizeof( info ) );
		int puan = StringToInt( info );
		if( g_puanmode[ param1 ] == 1 )
		{
			g_puan[ g_puantarget[ param1 ] ] += puan;
			CPrintToChatAll( "{darkblue}[ {orange}%N {darkblue}] {green}adlı yetkili {darkblue}[ {purple}%N {darkblue}] {green} adlı oyuncuya {darkblue}[ {darkred}%i puan {darkblue}] {green}verdi.", param1, g_puantarget[ param1 ], puan );
		}
		else
		{
			g_puan[ g_puantarget[ param1 ] ] -= puan;
			if( g_puan[ g_puantarget[ param1 ] ] < 0 ) g_puan[ g_puantarget[ param1 ] ] = 0;
			CPrintToChatAll( "{darkblue}[ {orange}%N {darkblue}] {green}adlı yetkili {darkblue}[ {purple}%N {darkblue}] {green} adlı oyuncudan {darkblue}[ {darkred}%i puan {darkblue}] {green}aldı.", param1, g_puantarget[ param1 ], puan );
		}
		g_puanmode[ param1 ] = -1;
		g_puantarget[ param1 ] = -1;
	}
}
public Action PuanList( int client, int args )
{
	int puan1, puan2, player1, player2, playersize, list_player[ MAXPLAYERS + 1 ], target;
	bool stop = false;
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame( i ) )
		{
			list_player[ playersize ] = i;
			playersize += 1;
		}
	}
	while( !stop )
	{
		stop = true;
		for( int i = 0; i < playersize - 1; i++ )
		{
			player1 = list_player[ i ];
			player2 = list_player[ i + 1 ];
			
			puan1 = g_puan[ player1 ];
			puan2 = g_puan[ player2 ];
			if( puan2 > puan1 )
			{
				stop = false;
				list_player[ i ] = player2;
				list_player[ i + 1 ] = player1;
			}
		}
	}
	Menu menu = new Menu( PuanList_Handler );
	menu.SetTitle( "Puan Sıralaması" );
	for( int i = 0; i < playersize; i++ )
	{
		target = list_player[ i ];
		char liste[ 32 ], text[ 128 ];
		Format( liste, sizeof( liste ), "%i", target );
		Format( text, sizeof( text ), "%N -> %i Puan", target, g_puan[ target ] );
		menu.AddItem( liste, text, ITEMDRAW_DISABLED ); 
	}
	menu.Display( client, MENU_TIME_FOREVER ); 
}
public int PuanList_Handler( Menu menu, MenuAction action, int param1, int param2 )
{
	if( action == MenuAction_Select )
	{
		char info[ 32 ];
		menu.GetItem( param2, info, sizeof( info ) );
	}
}
public Action Puanim( int client, int args )
{
	if( IsClientInGame( client ) )
	{
		CPrintToChat( client, "Toplamda {darkblue}[ {orange}%i puanın {darkblue}] {green}bulunuyor", g_puan[ client ] );
	}
	return Plugin_Handled;
}