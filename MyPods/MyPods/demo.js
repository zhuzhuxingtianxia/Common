//
defineProtocol('testProtocol',{
               newMethod:{
               //paramsType:"BOOL , float , CGFloat",
               //returnType:"int",
               },
               })

require('UIButton,UIColor');
defineClass('ViewController', {
            viewDidLoad: function() {
            //self.super().viewDidLoad();
            self.bulidView();
            self.upImageDownTextBageButtonTest();
            },
            upImageDownTextBageButtonTest: function(){},
            bulidView: function() {
            var btn = UIButton.buttonWithType(1);
            btn.setBounds({x:0, y:0, width:80, height:40});
            btn.setCenter(self.view().center());
            btn.setTitle_forState("谁是大神", 0);
            
            btn.setTitleColor_forState(UIColor.whiteColor(), 0);
            btn.setBackgroundColor(UIColor.colorWithRed_green_blue_alpha(80 / 255.0, 140 / 255.0, 238 / 255.0, 1.0));
            btn.layer().setCornerRadius(5.0);
            btn.layer().setMasksToBounds(1);
            
            btn.addTarget_action_forControlEvents(self, 'jsScriptRun:' , 1 <<  6);
            self.view().addSubview(btn);
            },
            
            jsScriptRun:function(obc){
            console.log(obc);
            var alertView = require('UIAlertView').alloc().init();
            alertView.setTitle('贾老师你说呢');
            alertView.setMessage('罗老师是不是大神');
            alertView.addButtonWithTitle('是的');
            alertView.addButtonWithTitle('必须是');
            alertView.show();
            }
            
            });
