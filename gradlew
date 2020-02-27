package com.medianet.cajas.server;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;

import android.support.v7.widget.Toolbar;
import android.view.ContextThemeWrapper;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.android.newpos.pay.R;
import com.android.newpos.pay.StartAppMEDIANET;
import com.medianet.definesMEDIANET.DefinesMEDIANET;
import com.medianet.menus.menus;


import java.net.InetAddress;
import java.net.UnknownHostException;

import cn.desert.newpos.payui.master.MasterControl;

import static com.android.newpos.pay.StartAppMEDIANET.VERSION;

public class ServerActivity extends AppCompatActivity {

    private static ThreadAttendRequest thread;
    private ImageView config;
    private TextView tv_versionC;
    public static Dialog dialog;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setContentView(R.layout.activity_server_tcp);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        MasterControl.setMcontext(this);
         agregarToolbar();
         setVersionC();

       if(thread == null){
           thread = new ThreadAttendRequest(this);
           thread.start();
       }

    }

    @Override
    protected void onResume() {
        super.onResume();
        menus.contFallback = 0;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public void verConfig(View v){

        String ip= getIP();
        String puerto= String.valueOf(Server.PORT);

        AlertDialog.Builder dialog= new AlertDialog.Builder(ServerActivity.this);
        dialog.setTitle("Configuración  actual de Conexión");

        if(ip.equalsIgnoreCase("0.0.0.0")){
            ip="No conectado a wifi";
            puerto="";
            dialog.setMessage("No conectado a la red Wifi");
        }else{
            dialog.setMessage("IP: "+ip+"\n"+"Puerto: "+puerto);
        }

       dialog.setPositiveButton("Aceptar", new DialogInterface.OnClickListener() {
           @Override
           public void onClick(DialogInterface dialog, int which) {
               dialog.dismiss();
           }
       });
       dialog.show();

    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public String getIP() {

        WifiManager wifiMan = (WifiManager)getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInf = wifiMan.getConnectionInfo();
        int ipAddress = wifiInf.getIpAddress();
        String mask= wifiInf.toString();
        String ip = String.format("%d.%d.%d.%d", (ipAddress & 0xff),(ipAddress >> 8 & 0xff),(ipAddress >> 16 & 0xff),(ipAddress >> 24 & 0xff));
        Toast.makeText(getApplicationContext(), ip, Toast.LENGTH_LONG).show();
        if(ip.equalsIgnoreCase("0.0.0.0")){
            try{
                
                InetAddress inetAdress = InetAddress.getLocalHost();
                ip = inetAdress.getHostAddress();
                Toast.makeText(getApplicationContext(), ip, Toast.LENGTH_LONG).show();
            } catch (Exception e) {
          //      e.printStackTrace();
            }

        }

        return ip;

    }

    private void settings() {
        ToneGenerator toneG = new ToneGenerator(AudioManager.STREAM_ALARM, 100);
        toneG.startTone(ToneGenerator.TONE_CDMA_PIP, 500);


        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.setClass(ServerActivity.this, menus.class);
        intent.putExtra(DefinesMEDIANET.DATO_MENU, DefinesMEDIANET.ITEM_COMUNICACION);
        startActivity(intent);
    }
    //--------------------------------------TOOLBAR Y MENU-----------------------------------------//
    private void agregarToolbar(){
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar_config);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(false);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main_conf, menu);
        return true;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        int id = item.getItemId();
        //Se dirige a la ventana AccesoAdministrador
        if(id == R.id.item_ip){
          